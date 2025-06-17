variable "gitea_username" {
  type        = string
  description = "Gitea username"
  sensitive   = true
}

variable "gitea_password" {
  type        = string
  description = "Gitea password"
  sensitive   = true
}

variable "github_mirror_token" {
  type        = string
  description = "value"
  sensitive   = true
}
