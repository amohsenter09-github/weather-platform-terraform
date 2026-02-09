locals {
  managed_node_groups = {
    default = {
      name           = "${var.name}-ng"
      instance_types = var.node_instance_types
      capacity_type  = var.node_capacity_type

      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size

      disk_size = var.node_disk_size
    }
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.24.0"

  cluster_name    = var.name
  cluster_version = var.kubernetes_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  # Avoid conflicts with leftover AWS resources from previous experiments.
  # You can re-enable these later if you want Terraform to manage them.
  #
  # 1) KMS key + alias (alias/eks/<cluster_name>)
  # 2) CloudWatch log group (/aws/eks/<cluster_name>/cluster)
  cluster_encryption_config   = {}
  create_kms_key              = false
  create_cloudwatch_log_group = false

  # Keep control-plane logging off by default to reduce CloudWatch cost.
  cluster_enabled_log_types = []

  # Access settings (dev-friendly defaults; tighten CIDRs in real usage).
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  cluster_endpoint_private_access      = true

  enable_irsa = true

  # Grant the Terraform caller (cluster creator) admin access via EKS access entry.
  # This enables kubectl access without managing aws-auth manually.
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  eks_managed_node_groups = local.managed_node_groups

  tags = var.tags
}

