output "certificate_arn" {
  value = aws_acm_certificate.this.arn
}

output "certificate_validation_status" {
  value = aws_acm_certificate_validation.this.validation_record_fqdns
}

