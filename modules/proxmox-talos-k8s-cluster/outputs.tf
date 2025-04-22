output "control_node_ids" {
  description = "Control node IDs"
  value       = [for vm in proxmox_virtual_environment_vm.control : vm.id]
}
