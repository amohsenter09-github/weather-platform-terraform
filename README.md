# weather-platform-terraform

Platform infrastructure: EKS, ECR, VPC, ACM, Argo CD, Kyverno, AI/MLOps scaffold.

**[docs/MLOPS-FLOW.md](docs/MLOPS-FLOW.md)** – Arrow diagrams for deployment flow, modules, data pipelines, and cluster topology.

### Manual Helm installs

For Helm-managed apps that you **do not** want Terraform to own (example: Argo CD), use:
- `helm/` (see `helm/README.md`)