# Kyverno – Admission Policies

Kyverno runs in each cluster and applies admission policies (validate/mutate) before resources are admitted.

## Layout

```
helm/kyverno/
├── applications.yaml   # Argo CD Applications (Kyverno + policies)
├── policies/           # ClusterPolicies (Kustomize)
│   ├── require-labels.yaml
│   ├── disallow-privileged.yaml
│   └── kustomization.yaml
└── README.md
```

## Deploy

### Prerequisites

1. Argo CD installed on the hub cluster.
2. Kyverno Helm repo added to Argo CD:

   ```bash
   argocd repo add https://kyverno.github.io/kyverno/ --type helm --name kyverno
   ```

3. This repo added to Argo CD (if not already):

   ```bash
   argocd repo add https://github.com/amohsenter09-github/weather-platform-terraform.git
   ```

### Apply Applications

```bash
kubectl apply -f helm/kyverno/
```

This creates 8 Applications:

- **kyverno-hub**, **kyverno-prod**, **kyverno-dev**, **kyverno-uat** – deploy Kyverno (Helm) to each cluster
- **kyverno-policies-hub**, **kyverno-policies-prod**, **kyverno-policies-dev**, **kyverno-policies-uat** – deploy ClusterPolicies to each cluster

## Policies

| Policy                    | Mode  | Description                          |
|---------------------------|-------|--------------------------------------|
| require-pod-labels        | Audit | Pods should have an `app` label       |
| disallow-privileged-containers | Audit | Block privileged containers (optional) |

Start with `validationFailureAction: Audit`; switch to `Enforce` after testing.

Edit `policies/kustomization.yaml` to enable `disallow-privileged.yaml`.

## Verify

```bash
kubectl -n kyverno get pods
kubectl get clusterpolicy
```
