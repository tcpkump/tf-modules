resource "proxmox_virtual_environment_vm" "control_plane" {
  count     = var.control_plane_nodes.count
  name      = "${var.cluster_name}-control-${count.index + 1}"
  node_name = var.proxmox_node_name
  tags      = concat(local.common_vm_tags, ["control-plane"])
  on_boot   = true
  bios      = "ovmf"

  agent {
    enabled = true
  }

  initialization {
    datastore_id = var.proxmox_vm_datastore_id
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

  tpm_state {
    datastore_id = var.proxmox_vm_datastore_id
    version      = "v2.0"
  }
  efi_disk {
    datastore_id = var.proxmox_vm_datastore_id
    file_format  = "raw"
    type         = "4m"
  }
  disk {
    datastore_id = var.proxmox_vm_datastore_id
    file_id      = proxmox_virtual_environment_download_file.talos_image.id
    interface    = "virtio0"
    size         = var.control_plane_nodes.vm_config.boot_disk_gb
    discard      = "on"
    ssd          = true
  }

  boot_order = ["virtio0"]

  depends_on = [
    proxmox_virtual_environment_download_file.talos_image,
  ]
}

resource "proxmox_virtual_environment_vm" "worker" {
  count     = var.worker_nodes.count
  name      = "${var.cluster_name}-worker-${count.index + 1}"
  node_name = var.proxmox_node_name
  tags      = concat(local.common_vm_tags, ["worker"])
  on_boot   = true
  bios      = "ovmf"

  agent {
    enabled = true
  }

  initialization {
    datastore_id = var.proxmox_vm_datastore_id
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

  tpm_state {
    datastore_id = var.proxmox_vm_datastore_id
    version      = "v2.0"
  }
  efi_disk {
    datastore_id = var.proxmox_vm_datastore_id
    file_format  = "raw"
    type         = "4m"
  }
  disk {
    datastore_id = var.proxmox_vm_datastore_id
    file_id      = proxmox_virtual_environment_download_file.talos_image.id
    interface    = "virtio0"
    size         = var.worker_nodes.vm_config.boot_disk_gb
    discard      = "on"
    ssd          = true
  }
  disk {
    datastore_id = var.proxmox_vm_datastore_id
    interface    = "virtio1"
    size         = var.worker_nodes.vm_config.storage_disk_gb
    discard      = "on"
    ssd          = true
  }

  boot_order = ["virtio0"]

  depends_on = [
    proxmox_virtual_environment_download_file.talos_image,
  ]
}
