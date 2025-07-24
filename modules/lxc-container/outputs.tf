output "container_ids" {
  description = "List of container VM IDs"
  value       = proxmox_virtual_environment_container.this[*].vm_id
}

output "container_hostnames" {
  description = "List of container hostnames"
  value       = proxmox_virtual_environment_container.this[*].initialization[0].hostname
}

output "container_ip_addresses" {
  description = "List of container IP addresses"
  value       = [for container in proxmox_virtual_environment_container.this : container.initialization[0].ip_config[0].ipv4[0].address]
}

output "container_names" {
  description = "List of container resource names"
  value       = [for i, container in proxmox_virtual_environment_container.this : "container-${i}"]
}
