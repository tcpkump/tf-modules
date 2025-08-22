run "basic" {
  command = apply

  assert {
    condition     = length(module.lxc_container.container_ids) == 2
    error_message = "Should create 2 containers"
  }

  assert {
    condition     = module.lxc_container.container_ids[0] == 900
    error_message = "First container should have VM ID 900"
  }

  assert {
    condition     = module.lxc_container.container_ids[1] == 901
    error_message = "Second container should have VM ID 901"
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
