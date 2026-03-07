terraform {
  backend "local" {
    path          = "state/terraform.tfstate"
    workspace_dir = "state/workspaces"
  }
}