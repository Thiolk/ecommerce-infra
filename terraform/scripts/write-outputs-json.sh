#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/write-outputs-json.sh dev
ENV="${1:-dev}"

cd terraform
terraform workspace select "$ENV" >/dev/null

terraform output -json > ../infra-outputs.json

echo "Wrote infra-outputs.json for workspace=$ENV"