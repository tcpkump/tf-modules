variable "proxmox_node_name" {
  type        = string
  description = "Proxmox node name"
}

variable "env" {
  type        = string
  description = "Environment name (dev, prod, etc.)"
}

variable "vlan_id" {
  type        = number
  description = "VLAN ID"
}

variable "vlan_interface" {
  type        = string
  description = "Network interface name"
}

variable "bridge_address" {
  type        = string
  description = "Bridge address"
}
