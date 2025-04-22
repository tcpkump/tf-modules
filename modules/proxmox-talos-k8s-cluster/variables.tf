variable "proxmox_node_name" {
  type        = string
  description = "Proxmox node name"
}

variable "env" {
  type        = string
  description = "Environment name (dev, prod, etc.)"
}

variable "proxmox_vm_datastore_id" {
  type        = string
  description = "Proxmox datastore ID"
}

variable "proxmox_iso_datastore_id" {
  type        = string
  description = "Proxmox datastore ID"
}

variable "talos_version" {
  type        = string
  description = "Talos version to use"
}

variable "ssh_public_keys" {
  type        = list(string)
  description = "List of SSH public keys to add to the VM"
  default     = []
}

variable "network_bridge" {
  description = "Network bridge to use for the VM"
  type        = string
}

variable "cpu_cores" {
  description = "Number of CPU cores for the VM"
  type        = number
  default     = 2
}

variable "disk_size" {
  description = "Disk size for the VM in GB"
  type        = number
  default     = 20
}

variable "control_plane_count" {
  description = "Number of control plane nodes"
  type        = number
  default     = 3
  validation {
    condition     = var.control_plane_count > 0 && var.control_plane_count <= 5
    error_message = "Control plane count must be greater than 0 and less than or equal to 5. 3 is default and recommended"
  }
}
