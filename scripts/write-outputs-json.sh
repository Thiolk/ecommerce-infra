#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/write-outputs-json.sh dev|staging|prod
ENV="${1:-dev}"

cd terraform
terraform workspace select "$ENV" >/dev/null 2>&1 || terraform workspace new "$ENV" >/dev/null

terraform output -json > "../infra-outputs.json"
terraform output -json > "../infra-outputs-${ENV}.json"

echo "Wrote infra-outputs.json and infra-outputs-${ENV}.json for workspace=$ENV"