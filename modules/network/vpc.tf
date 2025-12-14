# Network module (VPC/subnets/routing)
#
# This module is a thin wrapper around:
#   https://registry.terraform.io/modules/cn-terraform/networking/aws/latest
#
# It preserves a simple interface (lists of AZs + CIDRs) while leveraging the
# upstream module for actual AWS resources.

module "networking" {
  source  = "cn-terraform/networking/aws"
  version = "3.0.1"

  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets

  # Provider default_tags are already applied at the provider level in this repo,
  # but we pass tags through too so this module works even if default_tags changes.
  additional_tags = merge(var.tags, { Name = var.name })

  # Opinionated defaults; you can override via wrapper vars.
  single_nat              = var.single_nat
  map_public_ip_on_launch = var.map_public_ip_on_launch
}

locals {
  public_subnet_cidrs = length(var.public_subnet_cidrs) > 0 ? var.public_subnet_cidrs : [
    for i in range(length(var.azs)) : cidrsubnet(var.vpc_cidr, var.subnet_newbits, var.public_subnet_offset + i)
  ]

  private_subnet_cidrs = length(var.private_subnet_cidrs) > 0 ? var.private_subnet_cidrs : [
    for i in range(length(var.azs)) : cidrsubnet(var.vpc_cidr, var.subnet_newbits, var.private_subnet_offset + i)
  ]

  public_subnets = {
    for idx, az in var.azs : az => {
      availability_zone = az
      cidr_block        = local.public_subnet_cidrs[idx]
    }
  }

  private_subnets = {
    for idx, az in var.azs : az => {
      availability_zone = az
      cidr_block        = local.private_subnet_cidrs[idx]
    }
  }
}

