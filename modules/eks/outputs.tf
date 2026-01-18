output "cluster_name" {
  description = "EKS cluster name."
  value       = var.name
}

output "cluster_version" {
  description = "EKS cluster Kubernetes version."
  value       = var.kubernetes_version
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint."
  value       = module.eks.cluster_endpoint
}

output "cluster_ca_certificate" {
  description = "Base64-encoded CA cert data."
  value       = module.eks.cluster_certificate_authority_data
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN."
  value       = module.eks.oidc_provider_arn
}

output "cluster_security_group_id" {
  description = "Cluster security group ID."
  value       = module.eks.cluster_security_group_id
}

output "node_security_group_id" {
  description = "Node shared security group ID."
  value       = module.eks.node_security_group_id
}


