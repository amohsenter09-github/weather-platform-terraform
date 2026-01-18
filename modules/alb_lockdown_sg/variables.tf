variable "name" {
  description = "Security group name."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the ALB lives."
  type        = string
}

variable "allow_http" {
  description = "If true, allow port 80 from CloudFront as well as 443."
  type        = bool
  default     = true
}

variable "allow_https" {
  description = "If true, allow port 443 from CloudFront. Note: this may hit SG rule limits with the CloudFront prefix list in some accounts."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}

