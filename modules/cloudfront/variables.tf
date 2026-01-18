variable "name" {
  description = "Name/prefix for resources."
  type        = string
}

variable "aliases" {
  description = "Alternate domain names (CNAMEs) for the distribution."
  type        = list(string)
  default     = []
}

variable "viewer_certificate_acm_arn" {
  description = "ACM certificate ARN (must be in us-east-1 for CloudFront) for the distribution."
  type        = string
}

variable "origin_domain_name" {
  description = "Origin domain name (e.g. ALB DNS name)."
  type        = string
}

variable "origin_protocol_policy" {
  description = "Origin protocol policy (http-only, https-only, match-viewer)."
  type        = string
  default     = "https-only"
}

variable "web_acl_arn" {
  description = "Optional WAFv2 WebACL ARN to associate to the distribution."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}

