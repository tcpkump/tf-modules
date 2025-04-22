run "test" {
  command = apply

  assert {
    condition     = length(module.example_cluster.control_node_ids) > 0
    error_message = "Control node IDs should not be empty"
  }
}
