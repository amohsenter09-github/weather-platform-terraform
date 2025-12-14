output "vpc_id" {
  description = "VPC ID."
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = [for s in try(values(module.networking.public_subnets), module.networking.public_subnets) : s.id]
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = [for s in try(values(module.networking.private_subnets), module.networking.private_subnets) : s.id]
}


