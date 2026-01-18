resource "aws_ecrpublic_repository" "this" {
  repository_name = var.repository_name

  catalog_data {
    about_text        = var.about_text
    architectures     = var.architectures
    description       = var.description
    logo_image_blob   = var.logo_image_blob_base64
    operating_systems = var.operating_systems
    usage_text        = var.usage_text
  }

  tags = var.tags
}

data "aws_iam_policy_document" "public_pull" {
  statement {
    sid     = "AllowAnonymousPull"
    effect  = "Allow"
    actions = [
      "ecr-public:BatchCheckLayerAvailability",
      "ecr-public:BatchGetImage",
      "ecr-public:GetDownloadUrlForLayer",
      "ecr-public:DescribeImages",
      "ecr-public:DescribeRepositories",
      "ecr-public:GetRepositoryPolicy",
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_ecrpublic_repository_policy" "public_pull" {
  count = var.enable_anonymous_pull ? 1 : 0

  repository_name = aws_ecrpublic_repository.this.repository_name
  policy          = data.aws_iam_policy_document.public_pull.json
}

