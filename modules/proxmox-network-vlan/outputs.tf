output "vlan_id" {
  description = "VLAN ID"
  value       = proxmox_virtual_environment_network_linux_vlan.this.vlan
}
