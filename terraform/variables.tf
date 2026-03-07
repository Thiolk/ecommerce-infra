variable "minikube_profile" {
  type        = string
  description = "Minikube profile name"
  default     = "ecom"
}

variable "cpus" {
  type        = number
  description = "Minikube CPUs"
  default     = 4
}

variable "memory_mb" {
  type        = number
  description = "Minikube memory (MB)"
  default     = 8192
}

variable "dockerhub_user" {
  type        = string
  description = "Docker Hub username for image naming/outputs"
}

variable "ingress_namespace" {
  type    = string
  default = "ingress-nginx"
}

variable "ingress_controller_service" {
  type    = string
  default = "ingress-nginx-controller"
}

variable "jenkins_url" {
  type        = string
  description = "Jenkins base URL running on the host (external to Terraform)."
  default     = "http://localhost:8080"
}