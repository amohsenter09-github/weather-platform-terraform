# Multi-Cluster Environments

Four separate EKS clusters:

| Env   | Cluster Name       | Region     | Purpose                         | NAT Gateways |
|-------|--------------------|------------|---------------------------------|--------------|
| **hub**  | platform-hub-eks    | eu-west-2  | Argo CD, ApplicationSet (GitOps) | 1            |
| **prod** | platform-prod-eks   | eu-west-1  | Production workloads            | 1            |
| **dev**  | platform-dev-eks    | eu-west-1  | Development workloads           | 1            |
| **ua**   | platform-ua-eks     | eu-west-1  | UA / staging workloads          | 1            |

Each VPC uses **one NAT Gateway** for all private subnets (`single_nat = true`).

## Deploy

From repo root:

```bash
# Hub (eu-west-2) – run first
./scripts/apply.sh hub

# Spokes (eu-west-1)
./scripts/apply.sh prod
./scripts/apply.sh dev
./scripts/apply.sh ua
```

Two-phase apply for fresh clusters (k8s/helm providers need EKS first):

```bash
cd envs/<env>
terraform init -upgrade
terraform apply -target=module.network -target=module.eks
# For prod/dev/ua: also target ECR+ACM if desired
# terraform apply -target=module.network -target=module.eks -target=module.ecr_weather -target=module.ecr_air_quality -target=module.acm
terraform apply
```

## Connect to Clusters

```bash
# Hub
aws eks update-kubeconfig --region eu-west-2 --name platform-hub-eks

# Spokes
aws eks update-kubeconfig --region eu-west-1 --name platform-prod-eks
aws eks update-kubeconfig --region eu-west-1 --name platform-dev-eks
aws eks update-kubeconfig --region eu-west-1 --name platform-ua-eks
```

## Argo CD on Hub (via ALB)

Argo CD is exposed via an ALB at **https://argocd.cloud-master-ai.com** (configurable via `argocd_ingress_hostname`).

1. Apply hub infra: `./scripts/apply.sh hub`
2. Install Argo CD: `./scripts/install-argocd.sh hub`
3. Access: https://argocd.cloud-master-ai.com (admin password: `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d`)

## ECR Repos

- **prod**: `weather-platform`, `air-quality-platform` (canonical)
- **dev**: `weather-platform-dev`, `air-quality-platform-dev`
- **ua**: `weather-platform-ua`, `air-quality-platform-ua`
- **hub**: none (no app workloads)
