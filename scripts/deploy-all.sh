#!/usr/bin/env bash
# Full bootstrap: apply Terraform infrastructure, then install Argo CD.
# Run from repository root.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "${REPO_ROOT}"

echo "=========================================="
echo "Step 1: Deploy infrastructure (Terraform)"
echo "=========================================="
"${REPO_ROOT}/scripts/apply.sh"

echo ""
echo "=========================================="
echo "Step 2: Install Argo CD"
echo "=========================================="
"${REPO_ROOT}/scripts/install-argocd.sh"

echo ""
echo "=========================================="
echo "Bootstrap complete."
echo "=========================================="
