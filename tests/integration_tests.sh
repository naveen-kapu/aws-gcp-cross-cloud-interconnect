#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=== Integration tests: Terraform plan (AWS + GCP) ==="

echo "[AWS] terraform plan"
cd "${ROOT_DIR}/terraform/aws"
terraform init -backend=false >/dev/null
terraform plan -input=false -lock=false

echo "[GCP] terraform plan"
cd "${ROOT_DIR}/terraform/gcp"
terraform init -backend=false >/dev/null
terraform plan -input=false -lock=false

echo "Integration tests completed successfully ✅"
