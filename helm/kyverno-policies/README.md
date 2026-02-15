# Kyverno ClusterPolicies

Sample admission policies for the platform.

## Policies

- **require-labels**: Audit – Pods should have `app` label
- **block-privileged**: (Optional) Block privileged containers

## How they are deployed

Argo CD Applications (`kyverno-policies-hub`, `kyverno-policies-prod`, `kyverno-policies-dev`, `kyverno-policies-uat`) in `helm/argocd/kyverno/` deploy this folder to the hub and each workload cluster.

When you run:
```bash
kubectl apply -f helm/argocd/kyverno/
```

Argo CD will:
1. Deploy Kyverno (Helm) to prod, dev, ua
2. Deploy these ClusterPolicies (from this path) to prod, dev, ua

**Prereq**: Add this repo to Argo CD if not already:
```bash
argocd repo add https://github.com/amohsenter09-github/weather-platform-terraform.git
```
