terraform {
  required_version = ">= 1.9.0"
  required_providers {
    gitea = {
      source  = "go-gitea/gitea"
      version = ">= 0.6.0"
    }
  }
}
