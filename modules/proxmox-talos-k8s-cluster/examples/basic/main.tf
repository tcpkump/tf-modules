module "example_cluster" {
  source = "../../"

  cluster_name  = "example-talos-cluster"
  talos_version = "v1.9.5"

  proxmox_node_name        = "ryzen-proxmox"
  proxmox_vm_datastore_id  = "samsung-500gb"
  proxmox_iso_datastore_id = "local"
  network_bridge           = "vmbr200" # dev

  # control_plane_vip = "10.200.5.10"
  control_plane_nodes = {
    count = 1
    vm_config = {
      cores        = 2
      memory       = 2048 # Minimum
      boot_disk_gb = 10
    }
    ip_configs = [
      { ip = "10.200.5.1/16", gateway = "10.200.0.1" },
      # { ip = "10.200.5.2/16", gateway = "10.200.0.1" },
      # { ip = "10.200.5.3/16", gateway = "10.200.0.1" },
    ]
  }

  worker_nodes = {
    count = 1
    vm_config = {
      cores           = 2
      memory          = 2048
      boot_disk_gb    = 10
      storage_disk_gb = 10
    }
    use_dhcp = true
  }
}
