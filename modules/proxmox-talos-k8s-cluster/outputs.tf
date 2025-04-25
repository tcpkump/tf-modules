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
