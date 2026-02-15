variable "aws_region" {
  description = "AWS region for hub cluster."
  type        = string
  default     = "eu-west-2"
}

variable "node_desired_size" {
  type    = number
  default = 2
}
variable "node_min_size" {
  type    = number
  default = 2
}
variable "node_max_size" {
  type    = number
  default = 2
}
variable "node_capacity_type" {
  type    = string
  default = "ON_DEMAND"
}
variable "node_instance_types" {
  type    = list(string)
  default = ["t3a.small"]
}
variable "cluster_endpoint_public_access" {
  type    = bool
  default = true
}
variable "cluster_endpoint_public_access_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
variable "kubernetes_version" {
  type    = string
  default = "1.34"
}
variable "eks_console_admin_role_arn" {
  type    = string
  default = "arn:aws:iam::918780499156:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_cd90bbc6555a3922"
}
variable "eks_access_entries" {
  type    = any
  default = {}
}

variable "enable_kubernetes_addons" {
  description = "If true, install ALB controller and ExternalDNS for Argo CD Ingress."
  type        = bool
  default     = true
}

variable "route53_hosted_zone_id" {
  type    = string
  default = "Z05740989HOC6092S0FL"
}

variable "acm_domain_name" {
  type    = string
  default = "cloud-master-ai.com"
}

variable "acm_subject_alternative_names" {
  type    = list(string)
  default = ["*.cloud-master-ai.com"]
}

variable "external_dns_route53_zone_arns" {
  type    = list(string)
  default = []
}

variable "external_dns_domain_filters" {
  type    = list(string)
  default = ["cloud-master-ai.com"]
}

variable "argocd_ingress_hostname" {
  description = "Hostname for Argo CD Ingress (e.g. argocd.cloud-master-ai.com)."
  type        = string
  default     = "argocd.cloud-master-ai.com"
}

