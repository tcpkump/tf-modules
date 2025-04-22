resource "proxmox_virtual_environment_vm" "control" {
  count = var.control_plane_count
  name  = "talos-${var.env}-control-${count.index + 1}"
  # only support single proxmox node at the moment
  node_name = var.proxmox_node_name

  agent {
    enabled = true
  }

  initialization {
    user_account {
      keys = var.ssh_public_keys
    }
  }

  cpu {
    cores = var.cpu_cores
    type  = "x86-64-v2-AES"
  }

  network_device {
    bridge = var.network_bridge
  }

  disk {
    datastore_id = var.proxmox_vm_datastore_id
    file_id      = proxmox_virtual_environment_download_file.talos_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.disk_size
  }
}

resource "proxmox_virtual_environment_download_file" "talos_image" {
  content_type = "iso"
  datastore_id = var.proxmox_iso_datastore_id
  node_name    = var.proxmox_node_name
  url          = data.talos_image_factory_urls.this.urls.iso
  file_name    = "talos-${var.env}-${var.talos_version}.img"
}
