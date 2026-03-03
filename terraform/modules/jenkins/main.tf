resource "null_resource" "jenkins" {
  triggers = {
    port = tostring(var.jenkins_port)
    home = var.jenkins_home
  }

  provisioner "local-exec" {
    command = <<EOT
set -eux
mkdir -p "${var.jenkins_home}"

# stop existing
docker rm -f ecommerce-jenkins >/dev/null 2>&1 || true

docker run -d --name ecommerce-jenkins \
  -p ${var.jenkins_port}:8080 \
  -v "$(cd "${var.jenkins_home}" && pwd)":/var/jenkins_home \
  jenkins/jenkins:lts

EOT
    interpreter = ["/bin/bash", "-lc"]
  }
}