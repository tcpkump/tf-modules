module "example" {
  source = "../../"

  username            = "kumpy"
  name                = "test-gitea-repo-mirrored"
  description         = "This is a test gitea repository made my tf-modules/modules/gitea-repo/examples/mirrored"
  mirror_to_github    = true
  github_mirror_token = var.github_mirror_token
}
