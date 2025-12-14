data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  project = "weather-platform"
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


