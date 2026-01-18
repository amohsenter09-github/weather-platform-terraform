output "repository_name" {
  value = aws_ecrpublic_repository.this.repository_name
}

output "repository_arn" {
  value = aws_ecrpublic_repository.this.arn
}

output "repository_uri" {
  # Public ECR URIs are like: public.ecr.aws/<registry_alias>/<repo_name>
  value = aws_ecrpublic_repository.this.repository_uri
}

