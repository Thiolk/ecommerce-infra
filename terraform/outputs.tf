output "kube_context" {
  value = module.minikube.kube_context
}

output "minikube_profile" {
  value = var.minikube_profile
}

output "ingress_namespace" {
  value = var.ingress_namespace
}

output "ingress_controller_service" {
  value = var.ingress_controller_service
}

output "dockerhub_user" {
  value = var.dockerhub_user
}

output "frontend_host" {
  value = "frontend-${terraform.workspace}.local"
}

output "order_host" {
  value = "order-${terraform.workspace}.local"
}

output "product_host" {
  value = "product-${terraform.workspace}.local"
}

output "namespace" {
  value = terraform.workspace
}

output "jenkins_url" {
  value = var.jenkins_url
}