locals {
  env       = terraform.workspace
  namespace = terraform.workspace
}

module "minikube" {
  source           = "./modules/minikube"
  minikube_profile = var.minikube_profile
  cpus             = var.cpus
  memory_mb        = var.memory_mb
}

module "namespaces" {
  source     = "./modules/namespaces"
  namespaces = ["dev", "staging", "prod"]
  depends_on = [module.minikube]
}