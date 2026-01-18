data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  project = "platform"
  env     = "dev"

  name = "${local.project}-${local.env}"

  tags = {
    Project     = local.project
    Environment = local.env
    ManagedBy   = "Terraform"
  }

  # Pick first 3 AZs in eu-west-1 (provider is pinned to eu-west-1 in envs/dev/providers.tf).
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

module "network" {
  source = "../../modules/network"

  name     = local.name
  vpc_cidr = "10.0.0.0/16"
  azs      = local.azs

  # If you don't provide CIDRs, the module will derive them deterministically from vpc_cidr.
  # public_subnet_cidrs  = []
  # private_subnet_cidrs = []

  # NOTE: cn-terraform/networking/aws currently breaks with single_nat=true when using multiple AZs.
  # Keep it simple and reliable: create one NAT Gateway per AZ.
  single_nat = false

  # Subnet discovery tags for AWS Load Balancer Controller (ingress).
  # Option A: let the controller auto-discover subnets via tags.
  public_subnet_tags = {
    "kubernetes.io/role/elb"                          = "1"
    "kubernetes.io/cluster/${local.name}-eks"         = "shared"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"                 = "1"
    "kubernetes.io/cluster/${local.name}-eks"         = "shared"
  }

  tags = local.tags
}

module "eks" {
  source = "../../modules/eks"

  name               = "${local.name}-eks"
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  # Minimal-cost defaults live in the module:
  # - 1 node (min/max/desired = 1)
  # - t3a.small
  # - SPOT capacity
  node_desired_size = var.node_desired_size
  node_min_size     = var.node_min_size
  node_max_size     = var.node_max_size
  tags = local.tags
}

module "ecr" {
  source = "../../modules/ecr"

  repository_name = "weather-platform"
  tags            = local.tags
}

module "acm" {
  source = "../../modules/acm"

  domain_name               = var.acm_domain_name
  subject_alternative_names = var.acm_subject_alternative_names
  hosted_zone_id            = var.route53_hosted_zone_id
  tags                      = local.tags
}

module "acm_cloudfront" {
  source = "../../modules/acm"
  providers = {
    aws = aws.us_east_1
  }

  domain_name               = var.cloudfront_alias_domain
  subject_alternative_names = []
  hosted_zone_id            = var.route53_hosted_zone_id
  tags                      = local.tags
}

module "waf_cloudfront" {
  source = "../../modules/waf"
  providers = {
    aws = aws.us_east_1
  }

  name  = "${local.name}-cloudfront-waf"
  scope = "CLOUDFRONT"
  tags  = local.tags
}

module "cloudfront" {
  source = "../../modules/cloudfront"

  name                       = "${local.name}-cloudfront"
  aliases                    = [var.cloudfront_alias_domain]
  viewer_certificate_acm_arn = module.acm_cloudfront.certificate_arn
  origin_domain_name         = var.alb_origin_domain_name
  # Use HTTPS between CloudFront -> ALB (origin is a stable DNS name with a matching ACM cert).
  origin_protocol_policy     = "https-only"
  web_acl_arn                = module.waf_cloudfront.web_acl_arn
  tags                       = local.tags
}

module "alb_lockdown_sg" {
  source = "../../modules/alb_lockdown_sg"

  name   = "${local.name}-alb-cloudfront-only"
  vpc_id = module.network.vpc_id

  # Your ALB terminates TLS (Ingress listens on 443) and CloudFront -> origin is `https-only`,
  # so allow 443 from CloudFront origin-facing IP ranges. Keep 80 closed.
  allow_http  = false
  allow_https = true

  tags = local.tags
}

resource "aws_route53_record" "cloudfront_alias" {
  zone_id = var.route53_hosted_zone_id
  name    = var.cloudfront_alias_domain
  type    = "A"

  alias {
    name                   = module.cloudfront.domain_name
    zone_id                = module.cloudfront.hosted_zone_id
    evaluate_target_health = false
  }
}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  # We already manage core EKS managed addons in `modules/eks` (coredns, vpc-cni, kube-proxy),
  # so keep this empty to avoid duplicate resources.
  eks_addons = {}

  # Only what you asked for:
  enable_aws_load_balancer_controller = true
  enable_external_dns                 = true

  external_dns_route53_zone_arns = var.external_dns_route53_zone_arns
  # external-dns settings are passed as a loose map. We include the commonly-looked-up
  # keys to avoid type-mismatch issues in `lookup(...)` defaults inside the module.
  external_dns = {
    values = [
      yamlencode({
        domainFilters = var.external_dns_domain_filters
      })
    ]
    source_policy_documents   = []
    override_policy_documents = []
    role_permissions_boundary_arn = null
    role_policies            = {}
    policy_statements        = []
  }

  tags = local.tags
}


