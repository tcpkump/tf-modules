output "talosconfig" {
  description = "Talos client configuration (talosconfig)."
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = true
}

output "kubeconfig" {
  description = "Kubernetes client configuration (kubeconfig). Uses VIP endpoint if configured."
  value       = talos_cluster_kubeconfig.this.kubernetes_client_configuration
  sensitive   = true
}

output "cluster_endpoint" {
  description = "The effective cluster API endpoint (VIP if configured, otherwise first control plane node)."
  value       = local.effective_cluster_endpoint
}

output "control_plane_vip" {
  description = "The configured Control Plane VIP address (null if not configured)."
  value       = var.control_plane_vip # Directly output the input variable value
}

output "control_plane_vm_ids" {
  description = "List of Proxmox VM IDs for the control plane nodes."
  value       = proxmox_virtual_environment_vm.control_plane[*].vm_id
}

output "worker_vm_ids" {
  description = "List of Proxmox VM IDs for the worker nodes."
  value       = proxmox_virtual_environment_vm.worker[*].vm_id
}

output "control_plane_ips" {
  description = "List of static IP addresses assigned to control plane nodes."
  value       = local.control_plane_node_ips
}

output "bootstrap_node_ip" {
  description = "IP address of the control plane node used for bootstrapping."
  value       = local.bootstrap_node_ip
}
