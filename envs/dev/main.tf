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
  tags       = local.tags
}

module "eks" {
  source = "../../modules/eks"

  name               = "${local.name}-eks"
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids

  # Minimal-cost defaults live in the module:
  # - 1 node (min/max/desired = 1)
  # - t3a.small
  # - SPOT capacity
  node_desired_size = var.node_desired_size
  node_min_size     = var.node_min_size
  node_max_size     = var.node_max_size
  tags = local.tags
}


