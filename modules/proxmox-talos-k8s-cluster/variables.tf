variable "image" {
  description = "Talos image configuration"
  type = object({
    factory_url           = optional(string, "https://factory.talos.dev")
    schematic_path        = string
    version               = string
    update_schematic_path = optional(string)
    update_version        = optional(string)
    arch                  = optional(string, "amd64")
    platform              = optional(string, "nocloud")
    proxmox_datastore     = optional(string, "local")
  })
}

variable "cluster" {
  description = "Cluster configuration"
  type = object({
    name                                    = string
    vip                                     = optional(string)
    gateway                                 = string
    subnet_mask                             = optional(string, "16")
    talos_machine_config_version            = optional(string)
    proxmox_cluster                         = string
    kubernetes_version                      = string
    allow_scheduling_on_control_plane_nodes = optional(bool, false)
    extra_manifests                         = optional(list(string))
  })
}

variable "nodes" {
  description = "Configuration for cluster nodes"
  type = map(object({
    host_node      = string
    machine_type   = string
    datastore_id   = optional(string, "samsung-500gb")
    ip             = string
    dns            = optional(list(string))
    network_bridge = string
    vm_id          = number
    cpu            = number
    ram_dedicated  = number
    update         = optional(bool, false)
    igpu           = optional(bool, false)
  }))
}
