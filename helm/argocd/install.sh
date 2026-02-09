#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="argocd"
RELEASE="argocd"
REPO_NAME="argo"
REPO_URL="https://argoproj.github.io/argo-helm"
CHART="${REPO_NAME}/argo-cd"

kubectl get ns "${NAMESPACE}" >/dev/null 2>&1 || kubectl create namespace "${NAMESPACE}"

helm repo add "${REPO_NAME}" "${REPO_URL}" >/dev/null 2>&1 || true
helm repo update >/dev/null

helm upgrade --install "${RELEASE}" "${CHART}" \
  --namespace "${NAMESPACE}" \
  --values values.yaml \
  --wait \
  --timeout 10m

echo
echo "Argo CD installed."
echo
echo "Access (port-forward):"
echo "  kubectl -n ${NAMESPACE} port-forward svc/${RELEASE}-server 8080:443"
echo
echo "Get initial admin password:"
echo "  kubectl -n ${NAMESPACE} get secret ${RELEASE}-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo"

