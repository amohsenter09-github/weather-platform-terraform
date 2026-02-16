# Argo Workflows

ML pipeline orchestration. Deploy via Argo CD or Helm.

## Deploy

```bash
# Argo CD: add repo and create Application
argocd repo add https://argoproj.github.io/argo-helm --type helm --name argo
kubectl apply -f applications.yaml

# Or Helm directly
helm repo add argo https://argoproj.github.io/argo-helm
helm upgrade --install argo-workflows argo/argo-workflows -n argo --create-namespace
```
