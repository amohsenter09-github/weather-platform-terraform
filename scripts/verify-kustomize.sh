#!/usr/bin/env bash
# Verify Kustomize builds succeed for all kustomization directories.
# Usage: ./scripts/verify-kustomize.sh
# Run from repository root.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

if ! command -v kustomize &>/dev/null; then
  echo "Error: kustomize not found. Install via: go install sigs.k8s.io/kustomize/kustomize/v5@latest"
  exit 1
fi

FAILED=0
while IFS= read -r -d '' kfile; do
  dir="$(dirname "$kfile")"
  echo "==> kustomize build ${dir}"
  if output=$(kustomize build "$dir" 2>&1); then
    echo "    OK"
  else
    echo "    FAILED"
    echo "$output" | sed 's/^/    /'
    FAILED=1
  fi
done < <(find . -name 'kustomization.yaml' -not -path './.git/*' -print0)

if [[ ${FAILED} -ne 0 ]]; then
  exit 1
fi
echo ""
echo "All Kustomize builds passed."
