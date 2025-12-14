output "cluster_name" {
  description = "EKS cluster name."
  value       = var.name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint (wire once implemented)."
  value       = null
}

output "cluster_ca_certificate" {
  description = "Base64-encoded CA cert data (wire once implemented)."
  value       = null
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN (wire once implemented)."
  value       = null
}


