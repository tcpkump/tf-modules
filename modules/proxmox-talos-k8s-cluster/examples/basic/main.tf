module "example_cluster" {
  source = "../../"

  image = {
    version        = "v1.9.5"
    update_version = "v1.9.5"
    schematic_path = "../../image/schematic.yaml"
    # Point this to a new schematic file to update the schematic
    # update_schematic_path = "talos/image/schematic.yaml"
  }

  cluster = {
    name    = "talos-basic-example"
    vip     = "10.200.5.10"
    gateway = "10.200.0.1"
    # The version of talos features to use in generated machine configuration. Generally the same as image version.
    # See https://github.com/siderolabs/terraform-provider-talos/blob/main/docs/data-sources/machine_configuration.md
    # Uncomment to use this instead of version from talos_image.
    # talos_machine_config_version = "v1.9.5"
    proxmox_cluster                         = "ryzen-proxmox"
    kubernetes_version                      = "v1.32.3"
    allow_scheduling_on_control_plane_nodes = true
  }

  nodes = {
    "ctrl-00" = {
      host_node      = "ryzen-proxmox"
      machine_type   = "controlplane"
      ip             = "10.200.5.1"
      network_bridge = "vmbr200" # dev
      vm_id          = 800
      cpu            = 2
      ram_dedicated  = 2048
      igpu           = false
    }
    "ctrl-01" = {
      host_node      = "ryzen-proxmox"
      machine_type   = "controlplane"
      ip             = "10.200.5.2"
      network_bridge = "vmbr200" # dev
      vm_id          = 801
      cpu            = 2
      ram_dedicated  = 2048
      igpu           = false
      #update        = true
    }
    "ctrl-02" = {
      host_node      = "ryzen-proxmox"
      machine_type   = "controlplane"
      ip             = "10.200.5.3"
      network_bridge = "vmbr200" # dev
      vm_id          = 802
      cpu            = 2
      ram_dedicated  = 2048
      #update        = true
    }
    #    "work-00" = {
    #      host_node     = "abel"
    #      machine_type  = "worker"
    #      ip            = "192.168.1.110"
    #      dns           = ["1.1.1.1", "8.8.8.8"] # Optional Value.
    #      vm_id         = 810
    #      cpu           = 8
    #      ram_dedicated = 4096
    #    }
  }

}
