provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.tags
  }
}

# Kubernetes & Helm are typically configured from EKS outputs.
# These are left unconfigured at the root to keep `terraform validate` friendly
# before the EKS cluster exists; configure them in `envs/*` once EKS is created.
#
# provider "kubernetes" {
#   host                   = module.eks.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
#   token                  = data.aws_eks_cluster_auth.this.token
# }
#
# provider "helm" {
#   kubernetes {
#     host                   = module.eks.cluster_endpoint
#     cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
#     token                  = data.aws_eks_cluster_auth.this.token
#   }
# }


