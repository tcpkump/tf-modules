resource "proxmox_virtual_environment_container" "this" {
  count       = var.container_count
  description = "Managed by Terraform"

  node_name     = var.host_node
  vm_id         = var.id[count.index]
  unprivileged  = true
  start_on_boot = true
  started       = true

  cpu {
    cores = var.cpu
  }

  memory {
    dedicated = var.mem
  }

  disk {
    datastore_id = var.disk_location[count.index % length(var.disk_location)]
    size         = parseint(regex("([0-9]+)", var.disk_size)[0], 10)
  }

  initialization {
    hostname = var.container_count > 1 ? "${var.name}${count.index + 1}" : var.name

    ip_config {
      ipv4 {
        address = var.ip[count.index] == "dhcp" ? "dhcp" : "${var.ip[count.index]}/24"
        gateway = var.ip[count.index] == "dhcp" ? null : var.gateway
      }
    }

    user_account {
      keys = var.ssh_keys
    }
  }

  network_interface {
    name   = "veth0"
    bridge = var.network_bridge
  }

  operating_system {
    template_file_id = var.template_file_id
    type             = var.os_type
  }

  features {
    nesting = var.nesting
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      node_name,
      initialization[0].user_account[0].keys,
      network_interface,
    ]
  }
}
