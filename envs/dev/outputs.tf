output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_ca_certificate" {
  value = module.eks.cluster_ca_certificate
}

output "eks_oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "acm_certificate_arn" {
  value = module.acm.certificate_arn
}

output "cloudfront_domain_name" {
  value = module.cloudfront.domain_name
}

output "cloudfront_distribution_id" {
  value = module.cloudfront.distribution_id
}

output "cloudfront_alias_domain" {
  value = var.cloudfront_alias_domain
}

output "cloudfront_waf_web_acl_arn" {
  value = module.waf_cloudfront.web_acl_arn
}

output "acm_cloudfront_certificate_arn" {
  value = module.acm_cloudfront.certificate_arn
}

output "alb_cloudfront_only_security_group_id" {
  value = module.alb_lockdown_sg.security_group_id
}


