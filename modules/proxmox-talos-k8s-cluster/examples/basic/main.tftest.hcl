run "test" {
  command = apply

  assert {
    condition     = length(module.example_cluster.control_node_ids) > 0
    error_message = "Control node IDs should not be empty"
  }
}

run "basic" {
  command = apply

  assert {
    condition     = length(output.talosconfig) > 100 # Basic check it's not empty/trivial
    error_message = "talosconfig output is missing or empty"
  }
  assert {
    condition     = length(output.kubeconfig) > 100 # Basic check it's not empty/trivial
    error_message = "kubeconfig output is missing or empty"
  }
  assert {
    # Check if all VM IDs are numbers (typical Proxmox VM IDs)
    condition     = alltrue([for id in output.control_plane_vm_ids : can(tonumber(id))])
    error_message = "Control plane VM IDs are not all numeric"
  }
  assert {
    # Check worker IDs only if count > 0
    condition     = var.worker_nodes.count == 0 || alltrue([for id in output.worker_vm_ids : can(tonumber(id))])
    error_message = "Worker VM IDs are not all numeric"
  }
  assert {
    condition     = length(output.control_plane_ips) == var.control_plane_nodes.count
    error_message = "Incorrect number of control plane IPs in output"
  }

  assert {
    # Verify the bootstrap node IP is the first CP node's configured IP
    condition     = output.bootstrap_node_ip == split("/", var.control_plane_nodes.ip_configs[0].ip)[0]
    error_message = "Bootstrap node IP does not match the first control plane node's IP"
  }
  assert {
    # Verify the list of control plane IPs matches the derived IPs from input
    condition     = toset(output.control_plane_ips) == toset([for ipc in var.control_plane_nodes.ip_configs : split("/", ipc.ip)[0]])
    error_message = "Output control_plane_ips do not match the IPs derived from input variables"
  }
}
