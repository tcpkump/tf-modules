module "example_cluster" {
  source = "../../"

  proxmox_node_name        = "ryzen-proxmox"
  proxmox_vm_datastore_id  = "samsung-500gb"
  proxmox_iso_datastore_id = "local"
  network_bridge           = "vmbr200" # dev

  talos_version = "v1.9.5"

  env = "example"
}
