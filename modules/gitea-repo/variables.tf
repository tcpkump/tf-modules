variable "username" {
  description = "Repository owner"
  type        = string
}

variable "name" {
  description = "Repository name"
  type        = string
}

variable "description" {
  description = "Repository description"
  type        = string
}

variable "mirror_to_github" {
  description = "Whether to mirror to github"
  type        = bool
  default     = false
}

variable "github_mirror_token" {
  description = "token for mirroring to github. Required if var.mirror_to_github is true"
  type        = string
  sensitive   = true
  default     = null
}
