provider "gitea" {
  base_url = "https://git.imkumpy.in/"

  username = var.gitea_username
  password = var.gitea_password
}
