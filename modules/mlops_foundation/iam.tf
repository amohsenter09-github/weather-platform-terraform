# IAM role + IRSA for training/inference pods
# MLOps Foundations – requires EKS OIDC
# data "aws_iam_openid_connect_provider" "eks" { ... }
# resource "aws_iam_role" "mlops" { ... }
# resource "aws_iam_role_policy" "mlops_s3" { ... }
