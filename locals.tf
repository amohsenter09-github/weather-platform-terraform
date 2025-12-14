locals {
  project = "weather-platform"
  env     = var.env

  name_prefix = "${local.project}-${local.env}"

  tags = merge(
    {
      Project     = local.project
      Environment = local.env
      ManagedBy   = "Terraform"
    },
    var.extra_tags
  )
}

variable "env" {
  description = "Environment name (e.g. dev, staging, prod)."
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
}

variable "extra_tags" {
  description = "Additional tags to apply to AWS resources."
  type        = map(string)
  default     = {}
}


