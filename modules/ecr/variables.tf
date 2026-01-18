variable "repository_name" {
  description = "ECR (private) repository name."
  type        = string
}

variable "scan_on_push" {
  description = "Enable image scan on push."
  type        = bool
  default     = true
}

variable "image_tag_mutability" {
  description = "Tag mutability setting."
  type        = string
  default     = "MUTABLE"
}

variable "encryption_type" {
  description = "ECR encryption type. One of AES256 or KMS."
  type        = string
  default     = "AES256"
}

variable "kms_key_arn" {
  description = "KMS key ARN when encryption_type is KMS."
  type        = string
  default     = null
}

variable "force_delete" {
  description = "If true, delete the repository even if it contains images."
  type        = bool
  default     = true
}

variable "lifecycle_policy_json" {
  description = "Optional lifecycle policy JSON."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}

