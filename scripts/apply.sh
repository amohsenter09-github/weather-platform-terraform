#!/usr/bin/env bash
# Deploy platform infrastructure for a given env.
# Usage: ./scripts/apply.sh [hub|prod|dev|ua]
# Run from repository root.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV="${1:-cluster}"

case "${ENV}" in
  hub|prod|dev|ua)
    ENV_DIR="${REPO_ROOT}/envs/${ENV}"
    ;;
  cluster)
    ENV_DIR="${REPO_ROOT}/envs/cluster"
    ;;
  *)
    echo "Usage: $0 [hub|prod|dev|ua|cluster]"
    exit 1
    ;;
esac

cd "${REPO_ROOT}"

echo "==> Terraform init (env=${ENV})"
terraform -chdir="${ENV_DIR}" init -upgrade

echo ""
echo "==> Terraform plan"
terraform -chdir="${ENV_DIR}" plan -out=tfplan

echo ""
echo "==> Terraform apply"
terraform -chdir="${ENV_DIR}" apply tfplan

echo ""
echo "==> Done. Outputs:"
terraform -chdir="${ENV_DIR}" output
