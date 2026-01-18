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

