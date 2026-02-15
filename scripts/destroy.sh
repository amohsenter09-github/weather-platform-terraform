#!/usr/bin/env bash
# Destroy all platform infrastructure.
# Run from repository root.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_DIR="${REPO_ROOT}/envs/cluster"

cd "${REPO_ROOT}"

echo "==> Destroying infrastructure (envs/cluster)"
terraform -chdir="${ENV_DIR}" destroy -auto-approve

echo ""
echo "==> Done. All resources destroyed."
