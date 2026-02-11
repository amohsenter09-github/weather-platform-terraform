variable "node_desired_size" {
  description = "Desired node count for the dev EKS managed node group. Set to 0 to stop worker nodes."
  type        = number
  default     = 1

  validation {
    condition = (
      var.node_desired_size >= 0 &&
      var.node_min_size <= var.node_desired_size &&
      var.node_desired_size <= var.node_max_size
    )
    error_message = "Invalid node sizes: must satisfy node_min_size <= node_desired_size <= node_max_size (set all to 0 if you want to stop nodes)."
  }
}

variable "node_min_size" {
  description = "Minimum node count for the dev EKS managed node group."
  type        = number
  default     = 0

  validation {
    condition     = var.node_min_size >= 0
    error_message = "node_min_size must be >= 0."
  }
}

variable "node_max_size" {
  description = "Maximum node count for the dev EKS managed node group."
  type        = number
  default     = 1

  validation {
    condition     = var.node_max_size >= 0
    error_message = "node_max_size must be >= 0."
  }
}

variable "node_capacity_type" {
  description = "EKS managed node group capacity type: ON_DEMAND (reliable) or SPOT (cheapest)."
  type        = string
  default     = "SPOT"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "node_capacity_type must be one of: ON_DEMAND, SPOT."
  }
}

variable "node_instance_types" {
  description = "Instance types for the EKS managed node group."
  type        = list(string)
  default     = ["t3a.small"]
}

variable "cluster_endpoint_public_access" {
  description = "Whether the EKS API endpoint should be publicly accessible."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDRs allowed to access the public EKS API endpoint (only used if cluster_endpoint_public_access=true)."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version (e.g. 1.34)."
  type        = string
  default     = "1.34"
}

variable "eks_console_admin_role_arn" {
  description = "IAM role ARN to grant EKS admin access for AWS Console (commonly an IAM Identity Center AWSReservedSSO role). Set to empty string to disable."
  type        = string
  default     = "arn:aws:iam::918780499156:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_cd90bbc6555a3922"
}

variable "eks_access_entries" {
  description = "Additional EKS access entries to merge in (advanced)."
  type        = any
  default     = {}
}

variable "external_dns_route53_zone_arns" {
  description = "Route53 hosted zone ARNs that ExternalDNS is allowed to manage."
  type        = list(string)
  default     = []
}

variable "external_dns_domain_filters" {
  description = "Optional domain filters for ExternalDNS (e.g. [\"example.com\"])."
  type        = list(string)
  default     = []
}

variable "acm_domain_name" {
  description = "Domain name for ACM certificate (e.g. cloud-master-ai.com)."
  type        = string
  default     = "cloud-master-ai.com"
}

variable "acm_subject_alternative_names" {
  description = "SANs for ACM certificate (e.g. [\"*.cloud-master-ai.com\"])."
  type        = list(string)
  default     = ["*.cloud-master-ai.com"]
}

variable "route53_hosted_zone_id" {
  description = "Route53 hosted zone ID for cloud-master-ai.com."
  type        = string
  default     = "Z05740989HOC6092S0FL"
}

variable "enable_kubernetes_addons" {
  description = "If true, install Kubernetes addons (ALB Controller, ExternalDNS) via Helm. For a brand-new cluster, apply once with this = false, then enable and apply again."
  type        = bool
  default     = false
}
