run "test" {
  command = apply

  assert {
    condition     = module.example_network.vlan_id == 49
    error_message = "VLAN ID should be 49"
  }
}
