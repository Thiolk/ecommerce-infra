resource "null_resource" "namespaces" {
  triggers = {
    ns = join(",", var.namespaces)
  }

  provisioner "local-exec" {
    command = <<EOT
set -eux
for ns in ${join(" ", var.namespaces)}; do
  kubectl get ns "$ns" >/dev/null 2>&1 || kubectl create ns "$ns"
done
EOT
    interpreter = ["/bin/bash", "-lc"]
  }
}