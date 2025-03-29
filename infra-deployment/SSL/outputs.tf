output "certificate_arn" {
  description = "ARN of the imported SSL certificate"
  value       = aws_acm_certificate.imported_cert.arn
}