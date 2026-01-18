variable "name" {
  description = "WAFv2 Web ACL name."
  type        = string
}

variable "scope" {
  description = "WAF scope: CLOUDFRONT or REGIONAL."
  type        = string
  default     = "CLOUDFRONT"
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}

variable "enable_managed_common_rules" {
  description = "Enable AWSManagedRulesCommonRuleSet."
  type        = bool
  default     = true
}

variable "enable_ip_reputation_rules" {
  description = "Enable AWSManagedRulesAmazonIpReputationList."
  type        = bool
  default     = true
}

variable "enable_rate_limit" {
  description = "Enable a simple rate-based rule."
  type        = bool
  default     = true
}

variable "rate_limit" {
  description = "Requests per 5-minute period per IP when rate limit is enabled."
  type        = number
  default     = 2000
}

variable "blocked_country_codes" {
  description = "List of ISO 3166-1 alpha-2 country codes to block at the edge (e.g. [\"US\",\"RU\"]). Empty list disables geo-blocking."
  type        = list(string)
  default     = []
}

