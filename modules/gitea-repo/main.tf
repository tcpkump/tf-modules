resource "gitea_repository" "this" {
  username    = var.username
  name        = var.name
  description = var.description

  mirror                          = var.mirror_to_github
  migration_clone_address         = var.mirror_to_github ? "https://github.com/tcpkump/${var.name}.git" : null
  migration_service               = var.mirror_to_github ? "github" : null
  migration_service_auth_username = var.mirror_to_github ? "tcpkump" : null
  migration_service_auth_token    = var.mirror_to_github ? var.github_mirror_token : null
}
