#!/usr/bin/env bash
# Install Argo CD on the EKS cluster after infrastructure is created.
# Usage: ./scripts/install-argocd.sh [hub|cluster]
#   hub    – Argo CD on hub cluster (eu-west-2), exposed via ALB at argocd.cloud-master-ai.com
#   cluster – Legacy single cluster (eu-west-1)
# Run from repository root.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV="${1:-cluster}"
ARGOCD_DIR="${REPO_ROOT}/helm/argocd"

case "${ENV}" in
  hub)
    ENV_DIR="${REPO_ROOT}/envs/hub"
    DEFAULT_REGION="eu-west-2"
    ;;
  cluster)
    ENV_DIR="${REPO_ROOT}/envs/cluster"
    DEFAULT_REGION="eu-west-1"
    ;;
  *)
    echo "Usage: $0 [hub|cluster]"
    exit 1
    ;;
esac

cd "${REPO_ROOT}"

CLUSTER_NAME=$(terraform -chdir="${ENV_DIR}" output -raw eks_cluster_name 2>/dev/null || true)
REGION="${AWS_REGION:-${DEFAULT_REGION}}"

if [[ -z "${CLUSTER_NAME:-}" ]]; then
  echo "Error: Could not get eks_cluster_name. Run 'terraform -chdir=${ENV_DIR} apply' first."
  exit 1
fi

echo "==> Configuring kubeconfig for cluster: ${CLUSTER_NAME} (region: ${REGION})"
aws eks update-kubeconfig --name "${CLUSTER_NAME}" --region "${REGION}"

echo ""
echo "==> Waiting for nodes to be Ready (up to 5m)"
kubectl wait --for=condition=Ready nodes --all --timeout=300s 2>/dev/null || {
  echo "Warning: Nodes not ready yet. Proceeding anyway; Argo CD install may take longer."
}

echo ""
echo "==> Installing Argo CD"
if [[ "${ENV}" == "hub" ]]; then
  ARGOCD_URL="https://$(terraform -chdir="${ENV_DIR}" output -raw argocd_ingress_hostname 2>/dev/null || echo "argocd.cloud-master-ai.com")"
  export ARGOCD_EXTERNAL_URL="${ARGOCD_URL}"
fi
"${ARGOCD_DIR}/install.sh"

echo ""
echo "==> Argo CD installed."
if [[ "${ENV}" == "hub" ]]; then
  ARGOCD_HOST=$(terraform -chdir="${ENV_DIR}" output -raw argocd_ingress_hostname 2>/dev/null || echo "argocd.cloud-master-ai.com")
  echo "  Access via ALB: https://${ARGOCD_HOST}"
  echo "  (DNS may take a few minutes to propagate. Admin password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)"
else
  echo "  kubectl -n argocd port-forward svc/argocd-server 8080:443"
  echo "  Then open https://localhost:8080"
fi
