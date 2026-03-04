resource "null_resource" "minikube_start" {
  triggers = {
    profile = var.minikube_profile
    cpus    = tostring(var.cpus)
    mem     = tostring(var.memory_mb)
  }

  provisioner "local-exec" {
    command = <<EOT
set -eux
minikube start -p "${var.minikube_profile}" --cpus=${var.cpus} --memory=${var.memory_mb}mb
minikube addons enable ingress -p "${var.minikube_profile}"
kubectl config use-context "minikube"
EOT
    interpreter = ["/bin/bash", "-lc"]
  }
}