variable "node_desired_size" {
  description = "Desired node count for the dev EKS managed node group. Set to 0 to stop worker nodes."
  type        = number
  default     = 0
}

variable "node_min_size" {
  description = "Minimum node count for the dev EKS managed node group."
  type        = number
  default     = 0
}

variable "node_max_size" {
  description = "Maximum node count for the dev EKS managed node group."
  type        = number
  default     = 1
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
  description = "Domain name for ACM certificate (e.g. infra-ai-art.delivery)."
  type        = string
  default     = "infra-ai-art.delivery"
}

variable "acm_subject_alternative_names" {
  description = "SANs for ACM certificate (e.g. [\"*.infra-ai-art.delivery\"])."
  type        = list(string)
  default     = ["*.infra-ai-art.delivery"]
}

variable "route53_hosted_zone_id" {
  description = "Route53 hosted zone ID for infra-ai-art.delivery."
  type        = string
  default     = "Z07291932MB8UPJBFNUYB"
}
