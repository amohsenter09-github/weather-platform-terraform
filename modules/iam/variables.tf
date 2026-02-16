variable "tags" {
  type    = map(string)
  default = {}
}

variable "role_name" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "oidc_provider_url" {
  type = string
}

variable "service_account_namespace" {
  type = string
}

variable "service_account_name" {
  type = string
}
