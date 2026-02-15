# Kyverno – Admission Policies

Kyverno runs in each cluster and applies admission policies (validate/mutate) before resources are admitted.

## Architecture

| Location | How deployed | Purpose |
|----------|---------------|---------|
| **Hub** | Terraform `helm_release` | Protects hub (Argo CD, Kyverno itself) |
| **Prod, Dev, UA** | Argo CD Applications | Protects workload clusters |

Argo CD (in the hub) deploys Kyverno to each spoke cluster. Kyverno runs in each cluster and only sees resources in that cluster.

## Deploy

### 1. Kyverno on hub (Terraform)

```bash
cd envs/hub
terraform apply  # Does not install Kyverno; Argo CD deploys it
```

### 2. Add Helm repo to Argo CD (one-time)

Argo CD must be able to fetch the Kyverno Helm chart. Add the repo:

```bash
argocd repo add https://kyverno.github.io/kyverno/ --type helm --name kyverno
```

Or via UI: Settings → Repositories → Connect Repo.

### 3. Kyverno on spoke clusters (Argo CD)

```bash
kubectl apply -f helm/argocd/kyverno/
```

This creates 4 Applications: kyverno-hub, kyverno-prod, kyverno-dev, kyverno-uat. Argo CD will deploy Kyverno to the hub and each spoke cluster.

### 4. ClusterPolicies (optional)

Deploy sample policies to each cluster. Create Argo CD Applications that use this repo as source, path `helm/kyverno-policies`, and destination = each spoke cluster.

## Policies

- **require-pod-labels**: Audit mode – Pods should have `app` label
- **disallow-privileged-containers**: (Optional) Block privileged containers

Start with `validationFailureAction: Audit`; switch to `Enforce` after testing.

## Verify

```bash
# Hub
kubectl -n kyverno get pods

# Spoke (switch context first)
kubectl config use-context <prod-context>
kubectl -n kyverno get pods
```
