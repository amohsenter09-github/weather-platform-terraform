data "aws_ec2_managed_prefix_list" "cloudfront_origin_facing" {
  # AWS-managed prefix list for CloudFront -> origin traffic.
  # Used to restrict ALB inbound to only CloudFront edge locations.
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_security_group" "this" {
  name        = var.name
  description = "ALB ingress restricted to CloudFront origin-facing IP ranges"
  vpc_id      = var.vpc_id

  tags = var.tags
}

resource "aws_security_group_rule" "ingress_https_from_cloudfront" {
  count             = var.allow_https ? 1 : 0
  type              = "ingress"
  security_group_id = aws_security_group.this.id

  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront_origin_facing.id]
  description     = "Allow HTTPS from CloudFront origin-facing prefix list"
}

resource "aws_security_group_rule" "ingress_http_from_cloudfront" {
  count             = var.allow_http ? 1 : 0
  type              = "ingress"
  security_group_id = aws_security_group.this.id

  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront_origin_facing.id]
  description     = "Allow HTTP from CloudFront origin-facing prefix list"
}

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.this.id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  description = "Allow all egress"
}

