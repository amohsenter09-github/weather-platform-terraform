data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  project = "platform"
  env     = "hub"
  name    = "${local.project}-${local.env}"

  tags = {
    Project     = local.project
    Environment = local.env
    ManagedBy   = "Terraform"
  }

  # EKS requires 2+ AZs; cn-terraform breaks with single_nat+multi-AZ
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  external_dns_route53_zone_arns_effective = length(var.external_dns_route53_zone_arns) > 0 ? var.external_dns_route53_zone_arns : [
    "arn:aws:route53:::hostedzone/${var.route53_hosted_zone_id}"
  ]

  default_eks_access_entries = length(trimspace(var.eks_console_admin_role_arn)) > 0 ? {
    sso_admin = {
      kubernetes_groups   = []
      principal_arn       = var.eks_console_admin_role_arn
      policy_associations = {
        admin = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = { type = "cluster" }
        }
      }
    }
  } : {}

  eks_access_entries_effective = merge(local.default_eks_access_entries, try(var.eks_access_entries, {}))
}

module "network" {
  source = "../../modules/network"

  name       = local.name
  vpc_cidr   = "10.10.0.0/16"
  azs        = local.azs
  single_nat = false # EKS requires 2 AZs; cn-terraform breaks with single_nat+multi-AZ

  public_subnet_tags = {
    "kubernetes.io/role/elb"                  = "1"
    "kubernetes.io/cluster/${local.name}-eks" = "shared"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"         = "1"
    "kubernetes.io/cluster/${local.name}-eks" = "shared"
  }

  tags = local.tags
}

module "eks" {
  source = "../../modules/eks"

  name                                  = "${local.name}-eks"
  vpc_id                                = module.network.vpc_id
  private_subnet_ids                    = module.network.private_subnet_ids
  kubernetes_version                    = var.kubernetes_version
  cluster_endpoint_public_access        = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  node_desired_size                     = var.node_desired_size
  node_min_size                         = var.node_min_size
  node_max_size                         = var.node_max_size
  node_capacity_type                    = var.node_capacity_type
  node_instance_types                   = var.node_instance_types
  access_entries                        = local.eks_access_entries_effective
  tags                                  = local.tags
}

module "acm" {
  source = "../../modules/acm"

  domain_name               = var.acm_domain_name
  subject_alternative_names = var.acm_subject_alternative_names
  hosted_zone_id            = var.route53_hosted_zone_id
  tags                      = local.tags
}

module "eks_blueprints_addons_alb" {
  count  = var.enable_kubernetes_addons ? 1 : 0
  source = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {}

  enable_aws_load_balancer_controller = true
  enable_external_dns                 = false

  aws_load_balancer_controller = {
    wait    = true
    timeout = 600
  }

  tags = local.tags
}

module "eks_blueprints_addons_external_dns" {
  count  = var.enable_kubernetes_addons ? 1 : 0
  source = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  depends_on = [module.eks_blueprints_addons_alb]

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {}

  enable_aws_load_balancer_controller = false
  enable_external_dns                 = true

  external_dns = merge(
    {
      wait    = true
      timeout = 600
    },
    {
      values = [
        yamlencode({
          domainFilters = var.external_dns_domain_filters
        })
      ]
      source_policy_documents       = []
      override_policy_documents   = []
      role_permissions_boundary_arn = null
      role_policies               = {}
      policy_statements           = []
    }
  )
  external_dns_route53_zone_arns = local.external_dns_route53_zone_arns_effective

  tags = local.tags
}

# Namespace for Argo CD (Ingress needs it to exist before Argo CD install)
resource "kubernetes_namespace_v1" "argocd" {
  count = var.enable_kubernetes_addons ? 1 : 0

  depends_on = [module.eks_blueprints_addons_external_dns]

  metadata {
    name = "argocd"
  }
}

# Ingress for Argo CD – exposes server via ALB.
# Install Argo CD (./scripts/install-argocd.sh hub) after apply.
# The ALB will 503 until Argo CD is installed.
resource "kubernetes_ingress_v1" "argocd" {
  count = var.enable_kubernetes_addons ? 1 : 0

  depends_on = [kubernetes_namespace_v1.argocd]

  metadata {
    name      = "argocd-server"
    namespace = kubernetes_namespace_v1.argocd[0].metadata[0].name

    annotations = {
      "alb.ingress.kubernetes.io/scheme"            = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"      = "ip"
      "alb.ingress.kubernetes.io/listen-ports"     = jsonencode([{ HTTPS = 443 }])
      "alb.ingress.kubernetes.io/ssl-redirect"      = "443"
      "alb.ingress.kubernetes.io/certificate-arn"   = module.acm.certificate_arn
      "alb.ingress.kubernetes.io/backend-protocol"  = "HTTPS"
      "external-dns.alpha.kubernetes.io/hostname"  = var.argocd_ingress_hostname
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      host = var.argocd_ingress_hostname
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "argocd-server"
              port {
                number = 443
              }
            }
          }
        }
      }
    }
  }
}
