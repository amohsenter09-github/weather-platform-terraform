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

variable "cloudfront_alias_domain" {
  description = "DNS name to point at CloudFront (use a different subdomain than the ALB/ExternalDNS-managed one)."
  type        = string
  default     = "cdn.cloud-master-ai.com"
}

variable "alb_origin_domain_name" {
  description = "ALB DNS name used as the CloudFront origin (from the Ingress ADDRESS hostname)."
  type        = string
  default     = ""
}

variable "waf_blocked_country_codes" {
  description = "List of ISO 3166-1 alpha-2 country codes to block in CloudFront WAF (e.g. [\"US\"]). Empty list disables geo-blocking."
  type        = list(string)
  default     = []
}
