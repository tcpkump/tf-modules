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

resource "talos_machine_configuration_apply" "control_plane" {
  count                       = var.control_plane_nodes.count
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.control_plane.machine_configuration
  node                        = local.control_plane_node_ips[count.index]
  config_patches = [
    yamlencode({
      machine = {
        install = {
          disk = "/dev/vda"
        }
      }
    })
  ]

  depends_on = [proxmox_virtual_environment_vm.control_plane]
}

resource "talos_machine_configuration_apply" "worker" {
  count                       = var.worker_nodes.count
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = local.worker_node_ips[count.index]
  config_patches = [
    yamlencode({
      machine = {
        install = {
          disk = "/dev/vda"
        }
      }
    })
  ]

  depends_on = [proxmox_virtual_environment_vm.worker]
}

resource "talos_machine_bootstrap" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  # Endpoint and Node MUST be the *actual* IP of the first control plane node for the bootstrap command
  endpoint = local.bootstrap_node_ip
  node     = local.bootstrap_node_ip

  depends_on = [talos_machine_configuration_apply.control_plane]
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.this
  ]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.bootstrap_node_ip
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  # Nodes list for direct talosctl access
  nodes = local.control_plane_node_ips
  # Endpoints list for talosctl can include node IPs and the VIP if desired
  endpoints = distinct(concat(local.control_plane_node_ips, var.control_plane_vip != null ? [var.control_plane_vip] : []))
}
