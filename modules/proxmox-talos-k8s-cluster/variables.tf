variable "cluster_name" {
  type        = string
  description = "Unique name for the Talos cluster (used in VM names and Talos config)."
  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.cluster_name))
    error_message = "Cluster name must be lowercase alphanumeric, starting/ending with a letter or number, and can contain hyphens."
  }
}

variable "talos_version" {
  type        = string
  description = "Talos version to use (e.g., 'v1.7.5')."
}

variable "proxmox_node_name" {
  type        = string
  description = "The Proxmox node where VMs will be created."
}

variable "proxmox_vm_datastore_id" {
  type        = string
  description = "The Proxmox storage ID where VM disks will be created."
}

variable "proxmox_iso_datastore_id" {
  type        = string
  description = "The Proxmox storage ID where the Talos ISO will be downloaded/stored."
}

variable "network_bridge" {
  description = "Network bridge to use for the VMs (e.g., 'vmbr0')."
  type        = string
}

variable "control_plane_nodes" {
  description = "Configuration for the control plane nodes."
  type = object({
    count = number
    vm_config = object({
      cores        = number
      memory       = number # In MiB
      boot_disk_gb = number
      cpu_type     = optional(string, "x86-64-v2-AES")
    })
    # List of static IP configurations. MUST match the count.
    ip_configs = list(object({
      ip      = string # e.g., "192.168.1.10/24"
      gateway = string # e.g., "192.168.1.1"
    }))
  })

  validation {
    condition     = var.control_plane_nodes.count > 0 && contains([1, 3, 5], var.control_plane_nodes.count)
    error_message = "Control plane count must be 1, 3, or 5 for etcd quorum."
  }
  validation {
    condition     = length(var.control_plane_nodes.ip_configs) == var.control_plane_nodes.count
    error_message = "The number of control plane 'ip_configs' must exactly match the control plane 'count'."
  }
  validation {
    condition     = alltrue([for ip_conf in var.control_plane_nodes.ip_configs : can(regex("\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}/\\d{1,2}", ip_conf.ip))])
    error_message = "Control plane IP addresses must be in CIDR notation (e.g., 192.168.1.10/24)."
  }
  validation {
    condition     = alltrue([for ip_conf in var.control_plane_nodes.ip_configs : can(regex("\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}", ip_conf.gateway))])
    error_message = "Control plane gateways must be valid IP addresses."
  }
}

variable "control_plane_vip" {
  type        = string
  description = "Optional: The Virtual IP address for the control plane API server. If provided, kube-vip will be configured."
  default     = null # Use null to indicate VIP is not requested
  validation {
    # Allow null or a valid IP address
    condition     = var.control_plane_vip == null || can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$", var.control_plane_vip))
    error_message = "Control plane VIP must be a valid IP address or null."
  }
}

variable "worker_nodes" {
  description = "Configuration for the worker nodes."
  type = object({
    count = number
    vm_config = object({
      cores           = number
      memory          = number # In MiB
      boot_disk_gb    = number
      storage_disk_gb = number
      cpu_type        = optional(string, "x86-64-v2-AES")
    })
    use_dhcp = optional(bool, true)
    # Only provide if use_dhcp is false. MUST match the count.
    ip_configs = optional(list(object({
      ip      = string # e.g., "192.168.1.100/24"
      gateway = string # e.g., "192.168.1.1"
    })), [])
  })

  validation {
    condition     = var.worker_nodes.count >= 0
    error_message = "Worker node count must be 0 or greater."
  }
  validation {
    condition     = (var.worker_nodes.use_dhcp == true) || (var.worker_nodes.use_dhcp == false && length(var.worker_nodes.ip_configs) == var.worker_nodes.count)
    error_message = "If 'use_dhcp' is false for workers, the number of 'ip_configs' must exactly match the worker 'count'."
  }
  validation {
    condition     = var.worker_nodes.use_dhcp || alltrue([for ip_conf in var.worker_nodes.ip_configs : can(regex("\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}/\\d{1,2}", ip_conf.ip))])
    error_message = "Worker static IP addresses must be in CIDR notation (e.g., 192.168.1.100/24)."
  }
  validation {
    condition     = var.worker_nodes.use_dhcp || alltrue([for ip_conf in var.worker_nodes.ip_configs : can(regex("\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}", ip_conf.gateway))])
    error_message = "Worker static gateways must be valid IP addresses."
  }
}

# -- Optional Advanced Configuration --
variable "talos_config_patches" {
  type        = list(string)
  description = "List of YAML strings to patch the machine configs (applied to ALL nodes)."
  default     = []
}

variable "talos_config_patches_control_plane" {
  type        = list(string)
  description = "List of YAML strings to patch ONLY the control plane machine configs."
  default     = []
}

variable "talos_config_patches_worker" {
  type        = list(string)
  description = "List of YAML strings to patch ONLY the worker machine configs."
  default     = []
}

variable "vm_tags" {
  type        = list(string)
  description = "List of tags to apply to the Proxmox VMs."
  default     = []
}
