output "talosconfig" {
  description = "Talos client configuration (talosconfig)."
  value       = module.example_cluster.talosconfig
  sensitive   = true
}
