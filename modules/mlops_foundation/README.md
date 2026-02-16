# MLOps Foundation

S3 buckets (raw, processed, features, artifacts) + IAM/IRSA for ML workloads.

## Resources (to implement)

- **s3.tf**: raw, processed, features, artifacts buckets
- **iam.tf**: IAM role + IRSA for training/inference pods

## Inputs

- `tags` (optional)
- `eks_cluster_oidc_issuer_url` (required for IRSA)
- `eks_cluster_oidc_provider_arn` (required for IRSA)
