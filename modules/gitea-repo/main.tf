resource "gitea_repository" "this" {
  username    = var.username
  name        = var.name
  description = var.description

  push_mirror {
    remote_address  = var.mirror_to_github ? "https://github.com/tcpkump/${var.name}.git" : null
    remote_username = var.mirror_to_github ? "github" : null
    remote_password = var.mirror_to_github ? var.github_mirror_token : null
    interval        = "1h0m0s"
    sync_on_commit  = true
  }
}
