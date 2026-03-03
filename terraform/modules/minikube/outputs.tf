output "kube_context" {
  value = "minikube"
}

output "minikube_ip" {
  value = trimspace(file("${path.module}/.minikube_ip.txt"))
}