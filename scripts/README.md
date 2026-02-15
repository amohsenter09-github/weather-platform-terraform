# Platform Scripts

Scripts for deploying and managing the platform infrastructure.

## Prerequisites

- AWS CLI configured (`aws configure` or `AWS_PROFILE`)
- Terraform >= 1.6
- kubectl
- Helm 3

## Usage

### 1. Deploy infrastructure

```bash
# Multi-cluster: hub, prod, dev, ua (see envs/README.md)
./scripts/apply.sh hub
./scripts/apply.sh prod
./scripts/apply.sh dev
./scripts/apply.sh ua

# Legacy single cluster
./scripts/apply.sh cluster
```

Runs `terraform init`, `plan`, and `apply` for the chosen env.

### 2. Install Argo CD (after infrastructure exists)

```bash
./scripts/install-argocd.sh
```

- Reads cluster name from Terraform output
- Updates kubeconfig
- Installs Argo CD via Helm
- Applies development/production projects

### 3. Full bootstrap (infra + Argo CD)

```bash
./scripts/deploy-all.sh
```

Runs both steps in sequence.

## After bootstrap

- **Argo CD UI**: `kubectl -n argocd port-forward svc/argocd-server 8080:443`, then https://localhost:8080
- **Admin password**: `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo`
