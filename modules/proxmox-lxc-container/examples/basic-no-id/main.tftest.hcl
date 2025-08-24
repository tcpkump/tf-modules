run "basic" {
  command = apply

  assert {
    condition     = length(module.lxc_container.container_ids) == 2
    error_message = "Should create 2 containers"
  }

  assert {
    condition = alltrue([
      for id in module.lxc_container.container_ids : can(tonumber(id))
    ])
    error_message = "All container IDs should be numbers"
  }

  assert {
    condition     = contains(module.lxc_container.container_hostnames, "test-container1")
    error_message = "Should contain hostname test-container1"
  }

  assert {
    condition     = contains(module.lxc_container.container_hostnames, "test-container2")
    error_message = "Should contain hostname test-container2"
  }
}
