module "example_network" {
  source = "../../"

  proxmox_node_name = "ryzen-proxmox"

  env            = "example"
  vlan_id        = 49
  vlan_interface = "enp4s0"
  bridge_address = "10.49.49.49/16"
}
