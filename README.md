
# Ecommerce Infrastructure (Terraform)

Infrastructure-as-Code for the **E-commerce Microservices Platform**.

This repository provisions and manages the **local development infrastructure** used by the project, including:

- Minikube Kubernetes cluster configuration
- Kubernetes namespaces for environment isolation
- Local development infrastructure resources
- CI/CD integration outputs for Jenkins pipelines

Terraform ensures **consistent, repeatable infrastructure provisioning** across environments.

---

# Architecture Overview

This Terraform project provides infrastructure for the microservices system:

- ecommerce-frontend (React UI)
- product-service (Product API)
- order-service (Order API)
- database (PostgreSQL)

The platform runs on a **local Kubernetes cluster (Minikube)** with environment isolation using namespaces:

| Environment | Namespace |
|-------------|-----------|
| dev | dev |
| staging | staging |
| prod | prod |

Application deployments are handled by **Jenkins pipelines**, while Terraform manages the **underlying infrastructure configuration**.

---

# Repository Structure

```
terraform/
  env/
    dev.tfvars
    staging.tfvars
    prod.tfvars

  modules/
    local_dev/
    minikube/
    namespaces/

  state/
    workspaces/
      dev/
      staging/
      prod/

  backend.tf
  main.tf
  outputs.tf
  providers.tf
  variables.tf
  versions.tf
```

Modules are used to organize infrastructure responsibilities and keep the configuration modular.

---

# Terraform Modules

## minikube

Configures the local **Minikube Kubernetes cluster** used for development and testing.

Responsible for:

- Minikube profile configuration
- Kubernetes cluster context setup
- Cluster accessibility for CI/CD pipelines

---

## namespaces

Creates Kubernetes namespaces used for environment isolation.

Namespaces created:

- dev
- staging
- prod

This ensures deployments across environments do not interfere with each other.

---

## local_dev

Configures additional local infrastructure resources required for development workflows.

Examples include:

- local networking configuration
- supporting infrastructure used by the CI/CD pipeline

---

# Terraform State Management

This project uses a **local Terraform backend** with workspace-based environment separation.

Backend configuration:

```
terraform {
  backend "local" {
    path          = "state/terraform.tfstate"
    workspace_dir = "state/workspaces"
  }
}
```

Workspace state files are stored under:

```
terraform/state/workspaces/
```

Each workspace maintains an independent state file.

Example:

```
state/workspaces/dev
state/workspaces/staging
state/workspaces/prod
```

This prevents infrastructure conflicts between environments.

---

# Terraform Workspaces

Workspaces are used to manage **multiple environments from a single configuration**.

Available workspaces:

- dev
- staging
- prod

Example commands:

```
cd terraform

terraform workspace list
terraform workspace select dev
terraform workspace select staging
terraform workspace select prod
```

---

# Environment Configuration

Environment-specific variables are stored in:

```
terraform/env/
```

Files:

- dev.tfvars
- staging.tfvars
- prod.tfvars

These files define configuration differences such as:

- namespace names
- cluster configuration parameters
- environment-specific infrastructure settings

---

# Running Terraform

All Terraform commands should be run from the **terraform directory**.

Initialize Terraform:

```
cd terraform
terraform init
```

Select workspace:

```
terraform workspace select dev
```

Plan infrastructure changes:

```
terraform plan -var-file="env/dev.tfvars"
```

Apply infrastructure changes:

```
terraform apply -var-file="env/dev.tfvars"
```

Repeat the process for staging and production environments.

---

# Terraform Outputs

Terraform outputs provide infrastructure information required by **Jenkins CI/CD pipelines**.

Example outputs:

- dockerhub_user
- frontend_host
- order_host
- product_host
- kube_context
- ingress_namespace
- ingress_controller_service
- jenkins_url
- namespace
- minikube_profile

Example command:

```
terraform output
```

Example output:

```
frontend_host = "frontend-prod.local"
kube_context = "minikube"
ingress_namespace = "ingress-nginx"
```

---

# Exporting Outputs for Jenkins

Jenkins pipelines retrieve infrastructure outputs using a helper script.

Script:

```
scripts/write-outputs-json.sh
```

Usage:

```
./scripts/write-outputs-json.sh dev
./scripts/write-outputs-json.sh staging
./scripts/write-outputs-json.sh prod
```

The script performs:

1. Workspace selection
2. Terraform output retrieval
3. JSON export

Generated files:

```
infra-outputs.json
infra-outputs-dev.json
infra-outputs-staging.json
infra-outputs-prod.json
```

These files are archived by Jenkins and used by service pipelines.

---

# Jenkins Integration

The Terraform pipeline exports infrastructure outputs for other pipelines.

Example Jenkins stage:

```
stage('Export Outputs') {
  steps {
    sh '''
      set -eux
      chmod +x ./scripts/write-outputs-json.sh
      ./scripts/write-outputs-json.sh "${TARGET_ENV}"
    '''
    archiveArtifacts artifacts: 'infra-outputs*.json', fingerprint: true
  }
}
```

Other microservice pipelines retrieve these artifacts and load them using:

```
deploy/ci/load-infra-outputs.sh
```

This allows pipelines to dynamically obtain:

- Kubernetes context
- ingress controller configuration
- service hostnames

---

# Retrieving Outputs in Pipelines

Service pipelines load Terraform outputs using:

```
eval "$(./deploy/ci/load-infra-outputs.sh)"
kubectl config use-context "$KUBE_CONTEXT"
```

This ensures deployments always target the correct Kubernetes cluster.

---

# Terraform State Backup Procedure

Terraform state files represent the current infrastructure configuration and must be protected.

State files are located in:

```
terraform/state/
```

Backup procedure:

1. Create a timestamped backup directory

```
mkdir -p backups/$(date +%Y%m%d-%H%M%S)
```

2. Copy Terraform state files

```
cp -r terraform/state backups/$(date +%Y%m%d-%H%M%S)/
```

3. Verify backup contents

```
ls backups/
```

Backups should be created:

- before major infrastructure changes
- before running terraform apply in production

---

# Verifying Infrastructure

After Terraform deployment, verify cluster health.

Check Minikube:

```
minikube status
```

Verify Kubernetes namespaces:

```
kubectl get namespaces
```

Verify ingress controller:

```
kubectl -n ingress-nginx get pods
```