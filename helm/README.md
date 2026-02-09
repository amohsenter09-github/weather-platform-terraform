### Manual Helm deployments (not managed by Terraform)

This folder is for **manual Helm installs** that you *do not* want Terraform to own (example: Argo CD).

Terraform in `envs/dev/` still manages the cluster + core addons (AWS Load Balancer Controller, ExternalDNS, etc).

### Recommended workflow

1) Connect kubectl to the cluster:

```bash
export AWS_PROFILE=aws-personal-account
aws eks update-kubeconfig --region eu-west-1 --name platform-dev-eks
kubectl get nodes
```

2) Install a chart from one of the subfolders (example: Argo CD):

```bash
cd helm/argocd
./install.sh
```

### Helm state isolation (optional)

If you want Helm caches/config to stay inside this repo (instead of `~/Library/...`), run:

```bash
export HELM_CONFIG_HOME="$(pwd)/.helm/config"
export HELM_CACHE_HOME="$(pwd)/.helm/cache"
export HELM_DATA_HOME="$(pwd)/.helm/data"
mkdir -p "$HELM_CONFIG_HOME" "$HELM_CACHE_HOME" "$HELM_DATA_HOME"
```

