variable "repository_name" {
  description = "ECR Public repository name."
  type        = string
}

variable "enable_anonymous_pull" {
  description = "If true, attach a repository policy that allows anonymous (public) image pull."
  type        = bool
  default     = true
}

variable "description" {
  description = "Optional repository description (catalog data)."
  type        = string
  default     = ""
}

variable "about_text" {
  description = "Optional about text (catalog data)."
  type        = string
  default     = ""
}

variable "usage_text" {
  description = "Optional usage text (catalog data)."
  type        = string
  default     = ""
}

variable "architectures" {
  description = "Optional supported architectures (catalog data)."
  type        = list(string)
  default     = ["x86-64"]
}

variable "operating_systems" {
  description = "Optional supported operating systems (catalog data)."
  type        = list(string)
  default     = ["Linux"]
}

variable "logo_image_blob_base64" {
  description = "Optional base64-encoded logo image (catalog data)."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}

