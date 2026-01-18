output "security_group_id" {
  value = aws_security_group.this.id
}

output "cloudfront_origin_facing_prefix_list_id" {
  value = data.aws_ec2_managed_prefix_list.cloudfront_origin_facing.id
}

