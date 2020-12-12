output "arn" {
  description = "delivers arn for the created certificate"
  value = aws_acm_certificate.cert.arn
}