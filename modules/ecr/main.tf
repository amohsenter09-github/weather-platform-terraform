resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key         = var.kms_key_arn
  }

  force_delete = var.force_delete
  tags         = var.tags
}

resource "aws_ecr_lifecycle_policy" "this" {
  count      = var.lifecycle_policy_json == null ? 0 : 1
  repository = aws_ecr_repository.this.name
  policy     = var.lifecycle_policy_json
}

