### Manual Helm deployments (not managed by Terraform)

This folder is for **manual Helm installs** that you *do not* want Terraform to own.

| Folder       | Purpose                                                |
|-------------|--------------------------------------------------------|
| `argocd/`   | Argo CD install (GitOps controller on hub)            |
| `kyverno/`  | Kyverno + policies (Argo CD Applications)             |

Terraform in `envs/` manages clusters and core addons (AWS Load Balancer Controller, ExternalDNS, etc).

### Recommended workflow

1) Connect kubectl to the cluster:

```bash
aws eks update-kubeconfig --region eu-west-2 --name platform-hub-eks
kubectl get nodes
```

2) Install Argo CD (hub):

```bash
cd helm/argocd
./install.sh
```

3) Deploy Kyverno via Argo CD:

```bash
kubectl apply -f helm/kyverno/
```

### Helm state isolation (optional)

If you want Helm caches/config to stay inside this repo (instead of `~/Library/...`), run:

```bash
export HELM_CONFIG_HOME="$(pwd)/.helm/config"
export HELM_CACHE_HOME="$(pwd)/.helm/cache"
export HELM_DATA_HOME="$(pwd)/.helm/data"
mkdir -p "$HELM_CONFIG_HOME" "$HELM_CACHE_HOME" "$HELM_DATA_HOME"
```

