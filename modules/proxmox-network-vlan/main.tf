resource "proxmox_virtual_environment_network_linux_vlan" "this" {
  node_name = var.proxmox_node_name
  name      = "vlan_${var.env}"

  interface = var.vlan_interface
  vlan      = var.vlan_id
  comment   = "VLAN ${var.vlan_id} - ${var.env}"
}

resource "proxmox_virtual_environment_network_linux_bridge" "this" {
  depends_on = [
    proxmox_virtual_environment_network_linux_vlan.this
  ]

  node_name = var.proxmox_node_name
  name      = "vmbr${var.vlan_id}"

  address = var.bridge_address

  comment = "vmbr${var.env} - VLAN ${var.vlan_id}"

  ports = [
    proxmox_virtual_environment_network_linux_vlan.this.name
  ]
}
