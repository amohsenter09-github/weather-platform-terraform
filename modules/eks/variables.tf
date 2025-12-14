variable "name" {
  description = "EKS cluster name."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the cluster."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the cluster/node groups."
  type        = list(string)
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS."
  type        = string
  default     = "1.29"
}

variable "tags" {
  description = "Tags to apply to EKS resources."
  type        = map(string)
  default     = {}
}


