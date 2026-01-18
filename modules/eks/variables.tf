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

variable "cluster_endpoint_public_access" {
  description = "Whether the EKS API endpoint is publicly accessible."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR blocks allowed to access the public EKS API endpoint. Tighten this in real deployments."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "node_instance_types" {
  description = "Instance types for the minimal managed node group."
  type        = list(string)
  default     = ["t3a.small"]
}

variable "node_capacity_type" {
  description = "Capacity type for nodes: SPOT (cheapest) or ON_DEMAND."
  type        = string
  default     = "SPOT"
}

variable "node_desired_size" {
  description = "Desired node count for the minimal node group."
  type        = number
  default     = 1
}

variable "node_min_size" {
  description = "Min node count for the minimal node group."
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Max node count for the minimal node group."
  type        = number
  default     = 1
}

variable "node_disk_size" {
  description = "Node root EBS volume size (GiB)."
  type        = number
  default     = 20
}


