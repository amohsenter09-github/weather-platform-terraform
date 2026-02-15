variable "aws_region" {
  description = "AWS region for development cluster."
  type        = string
  default     = "eu-west-1"
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
variable "external_dns_route53_zone_arns" {
  type    = list(string)
  default = []
}
variable "external_dns_domain_filters" {
  type    = list(string)
  default = []
}
variable "acm_domain_name" {
  type    = string
  default = "cloud-master-ai.com"
}
variable "acm_subject_alternative_names" {
  type    = list(string)
  default = ["*.cloud-master-ai.com"]
}
variable "route53_hosted_zone_id" {
  type    = string
  default = "Z05740989HOC6092S0FL"
}
variable "enable_kubernetes_addons" {
  type    = bool
  default = false
}
