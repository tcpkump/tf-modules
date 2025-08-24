variable "host_node" {
  type        = string
  description = "Proxmox node name where containers will be deployed"
}

variable "cpu" {
  type        = number
  description = "The number of CPU cores"
  default     = 1
}

variable "disk_location" {
  type        = list(string)
  description = "List of datastore IDs for container storage"
}

variable "disk_size" {
  type        = string
  description = "The size of container disk (e.g., '20G')"
  default     = "8G"
}

variable "id" {
  type        = list(number)
  description = "(Optional) List of VM IDs for containers, must match container_count length"
  default     = null
}

variable "container_count" {
  type        = number
  description = "Number of containers to deploy"
  default     = 1
}

variable "ip" {
  type        = list(string)
  description = "List of IP addresses or 'dhcp' for containers"
}

variable "name" {
  type        = string
  description = "Base hostname for containers"
}

variable "mem" {
  type        = number
  description = "Amount of RAM in MB"
  default     = 512
}

variable "ssh_keys" {
  description = "List of SSH public keys to add to containers"
  type        = list(string)
}

variable "template_file_id" {
  type        = string
  description = "Template file ID for the container OS"
}

variable "os_type" {
  type        = string
  description = "Operating system type (e.g., 'ubuntu', 'debian')"
  default     = "ubuntu"
}

variable "network_bridge" {
  type        = string
  description = "Network bridge name"
  default     = "vmbr0"
}

variable "gateway" {
  type        = string
  description = "Network gateway IP address"
  default     = null
}

variable "nesting" {
  type        = bool
  description = "Enable nesting feature for containers"
  default     = true
}

variable "tags" {
  type        = list(string)
  description = "List of tags to apply to containers"
  default     = []
}
