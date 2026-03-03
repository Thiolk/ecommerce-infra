 locals {
  env       = terraform.workspace
  namespace = terraform.workspace
}

module "minikube" {
  source          = "./modules/minikube"
  minikube_profile = var.minikube_profile
  cpus            = var.cpus
  memory_mb       = var.memory_mb
}

module "namespaces" {
  source     = "./modules/namespaces"
  namespaces = ["dev", "staging", "prod"]
  depends_on = [module.minikube]
}

module "jenkins" {
  source       = "./modules/jenkins"
  jenkins_port = var.jenkins_port
  jenkins_home = var.jenkins_home
}

# Optional: validate that workspace is one of the allowed envs
resource "null_resource" "validate_workspace" {
  triggers = {
    workspace = terraform.workspace
  }

  provisioner "local-exec" {
    command = <<EOT
set -e
case "${terraform.workspace}" in
  dev|staging|prod) echo "Workspace OK: ${terraform.workspace}" ;;
  *) echo "ERROR: workspace must be dev|staging|prod" && exit 1 ;;
esac
EOT
    interpreter = ["/bin/bash", "-lc"]
  }
}