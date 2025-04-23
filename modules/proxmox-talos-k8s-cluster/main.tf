locals {
  # Extract just the IP addresses for easier use in talos config
  control_plane_node_ips = [for ip_conf in var.control_plane_nodes.ip_configs : split("/", ip_conf.ip)[0]]
  # Use the first control plane node's IP for bootstrapping
  bootstrap_node_ip = local.control_plane_node_ips[0]

  # Use VIP if provided, otherwise fall back to the first control plane node IP for the cluster endpoint
  effective_cluster_endpoint_ip = var.control_plane_vip != null ? var.control_plane_vip : local.bootstrap_node_ip
  effective_cluster_endpoint    = "https://${local.effective_cluster_endpoint_ip}:6443"

  # Determine worker IPs based on DHCP flag
  worker_node_ips = var.worker_nodes.use_dhcp ? [] : [for ip_conf in var.worker_nodes.ip_configs : split("/", ip_conf.ip)[0]]

  common_vm_tags = concat(["talos", "kubernetes", var.cluster_name], var.vm_tags)

  # --- Configuration Patches ---
  # Define the kube-vip patch only if a VIP is provided
  kube_vip_patch = var.control_plane_vip != null ? yamlencode({
    machine = {
      network = {
        interfaces = [
          {
            # Selects the primary physical network interface.
            # Assumes there's at least one physical interface.
            deviceSelector = {
              physical = true
            }
            dhcp = false
            vip = {
              ip = var.control_plane_vip
            }
          }
        ]
      }
    }
  }) : "" # Return an empty string if no VIP is configured (var.control_plane_vip is null)

  # Merge common, role-specific, and VIP patches for control plane
  # Use compact() to remove empty strings (like the kube_vip_patch if VIP is null)
  control_plane_patches = compact(concat(
    var.talos_config_patches,
    var.talos_config_patches_control_plane,
    [local.kube_vip_patch] # Add the VIP patch here
  ))

  # Worker patches do not include the VIP config patch
  worker_patches = compact(concat(var.talos_config_patches, var.talos_config_patches_worker))

  # Define file name for the downloaded ISO
  iso_file_name = "talos-${var.cluster_name}-${var.talos_version}.iso"
}

# --- Talos Configuration Generation ---

resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version
}

data "talos_machine_configuration" "control_plane" {
  cluster_name = var.cluster_name
  # Use the endpoint derived from VIP or first node IP
  cluster_endpoint = local.effective_cluster_endpoint
  machine_type     = "controlplane"
  talos_version    = var.talos_version
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  # Apply merged patches including the conditional VIP patch
  config_patches = local.control_plane_patches

  docs     = false
  examples = false
}

data "talos_machine_configuration" "worker" {
  count = var.worker_nodes.count > 0 ? 1 : 0

  cluster_name = var.cluster_name
  # Workers also point to the effective cluster endpoint (VIP or first node)
  cluster_endpoint = local.effective_cluster_endpoint
  machine_type     = "worker"
  talos_version    = var.talos_version
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  config_patches   = local.worker_patches # Use worker-specific patches

  docs     = false
  examples = false
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  # Nodes list for direct talosctl access
  nodes = local.control_plane_node_ips
  # Endpoints list for talosctl can include node IPs and the VIP if desired
  endpoints = distinct(concat(local.control_plane_node_ips, var.control_plane_vip != null ? [var.control_plane_vip] : []))
}

# --- Talos Image Download ---
data "talos_image_factory_extensions_versions" "this" {
  talos_version = var.talos_version
  filters = {
    names = [
      "qemu",
    ]
  }
}

resource "talos_image_factory_schematic" "this" {
  count = length(data.talos_image_factory_extensions_versions.this.extensions_info) > 0 ? 1 : 0
  schematic = yamlencode({
    customization = {
      systemExtensions = {
        officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info.*.name
      }
    }
  })
}

data "talos_image_factory_urls" "this" {
  talos_version = var.talos_version
  schematic_id  = one(talos_image_factory_schematic.this[*].id) # Corrected from previous version
  platform      = "nocloud"
}

resource "proxmox_virtual_environment_download_file" "talos_image" {
  content_type = "iso"
  datastore_id = var.proxmox_iso_datastore_id
  node_name    = var.proxmox_node_name
  url          = data.talos_image_factory_urls.this.urls.iso
  file_name    = local.iso_file_name
}

# --- Proxmox VM Creation ---

resource "proxmox_virtual_environment_file" "control_plane_user_data" {
  # IMPORTANT: This datastore MUST be configured to allow 'Snippets' content type in Proxmox UI
  # (Datacenter -> Storage -> Your Storage -> Edit -> Content -> Select 'Snippets')
  # Often, 'local' storage is used for snippets. Adjust datastore_id if needed.
  datastore_id = var.proxmox_iso_datastore_id
  node_name    = var.proxmox_node_name
  content_type = "snippets"

  source_raw {
    data = data.talos_machine_configuration.control_plane.machine_configuration

    # Using a hash of the content helps Terraform detect changes
    file_name = "talos-control-userdata-${substr(sha1(data.talos_machine_configuration.control_plane.machine_configuration), 0, 8)}.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "control_plane" {
  count     = var.control_plane_nodes.count
  name      = "${var.cluster_name}-control-${count.index + 1}"
  node_name = var.proxmox_node_name
  tags      = concat(local.common_vm_tags, ["control-plane"])
  on_boot   = true

  initialization {
    datastore_id      = var.proxmox_vm_datastore_id
    user_data_file_id = proxmox_virtual_environment_file.control_plane_user_data.id
    ip_config {
      ipv4 {
        address = var.control_plane_nodes.ip_configs[count.index].ip
        gateway = var.control_plane_nodes.ip_configs[count.index].gateway
      }
    }
  }

  cpu {
    cores = var.control_plane_nodes.vm_config.cores
    type  = var.control_plane_nodes.vm_config.cpu_type
  }

  memory {
    dedicated = var.control_plane_nodes.vm_config.memory
  }

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  disk {
    datastore_id = var.proxmox_vm_datastore_id
    file_id      = proxmox_virtual_environment_download_file.talos_image.id
    interface    = "scsi0"
    size         = var.control_plane_nodes.vm_config.disk_gb
    discard      = "on"
    ssd          = true
  }

  depends_on = [
    proxmox_virtual_environment_download_file.talos_image,
    proxmox_virtual_environment_file.control_plane_user_data
  ]
}

resource "proxmox_virtual_environment_file" "worker_user_data" {
  count = var.worker_nodes.count > 0 ? 1 : 0
  # IMPORTANT: This datastore MUST be configured to allow 'Snippets' content type in Proxmox UI
  # (Datacenter -> Storage -> Your Storage -> Edit -> Content -> Select 'Snippets')
  # Often, 'local' storage is used for snippets. Adjust datastore_id if needed.
  datastore_id = var.proxmox_iso_datastore_id
  node_name    = var.proxmox_node_name
  content_type = "snippets"

  source_raw {
    data = one(data.talos_machine_configuration.worker[*].machine_configuration)

    # Using a hash of the content helps Terraform detect changes
    file_name = "talos-worker-userdata-${substr(sha1(one(data.talos_machine_configuration.worker[*].machine_configuration)), 0, 8)}.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "worker" {
  count     = var.worker_nodes.count
  name      = "${var.cluster_name}-worker-${count.index + 1}"
  node_name = var.proxmox_node_name
  tags      = concat(local.common_vm_tags, ["worker"])
  on_boot   = true

  initialization {
    datastore_id      = var.proxmox_vm_datastore_id
    user_data_file_id = one(proxmox_virtual_environment_file.worker_user_data[*].id)
    ip_config {
      dynamic "ipv4" {
        for_each = var.worker_nodes.use_dhcp ? [1] : []
        content { address = "dhcp" }
      }
      dynamic "ipv4" {
        for_each = !var.worker_nodes.use_dhcp ? [1] : []
        content {
          address = var.worker_nodes.ip_configs[count.index].ip
          gateway = var.worker_nodes.ip_configs[count.index].gateway
        }
      }
    }
  }

  cpu {
    cores = var.worker_nodes.vm_config.cores
    type  = var.worker_nodes.vm_config.cpu_type
  }

  memory {
    dedicated = var.worker_nodes.vm_config.memory
  }

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  disk {
    datastore_id = var.proxmox_vm_datastore_id
    file_id      = proxmox_virtual_environment_download_file.talos_image.id
    interface    = "scsi0"
    size         = var.worker_nodes.vm_config.disk_gb
    discard      = "on"
    ssd          = true
  }

  depends_on = [
    proxmox_virtual_environment_download_file.talos_image,
    proxmox_virtual_environment_vm.control_plane,
    proxmox_virtual_environment_file.worker_user_data
  ]
}

resource "talos_machine_bootstrap" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  # Endpoint and Node MUST be the *actual* IP of the first control plane node for the bootstrap command
  endpoint = local.bootstrap_node_ip
  node     = local.bootstrap_node_ip

  depends_on = [proxmox_virtual_environment_vm.control_plane[0]]
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.this
  ]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.bootstrap_node_ip
}
