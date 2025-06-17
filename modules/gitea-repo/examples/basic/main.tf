module "example" {
  source = "../../"

  username    = "kumpy"
  name        = "test-gitea-repo"
  description = "This is a test gitea repository made my tf-modules/modules/gitea-repo/examples/basic"
}
