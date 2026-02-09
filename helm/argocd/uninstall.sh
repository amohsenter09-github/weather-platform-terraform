#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="argocd"
RELEASE="argocd"

helm -n "${NAMESPACE}" uninstall "${RELEASE}" || true
kubectl delete namespace "${NAMESPACE}" --wait=false || true

echo "Argo CD removed."

