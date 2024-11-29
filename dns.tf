# Custom Domain for API Gateway
resource "aws_apigatewayv2_domain_name" "custom_domain" {
  domain_name = var.custom_domain_name

  domain_name_configuration {
    certificate_arn = aws_acm_certificate_validation.custom_domain_cert_validation.certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

  depends_on = [aws_acm_certificate_validation.custom_domain_cert_validation]
}

# Create ACM Certificate
resource "aws_acm_certificate" "custom_domain_cert" {
  domain_name       = var.custom_domain_name
  validation_method = "DNS"

  tags = {
    Name = "SSL Cert for ${var.custom_domain_name}"
  }
}

# DNS Validation Records
resource "aws_route53_record" "cert_validation" {
  for_each = { for option in aws_acm_certificate.custom_domain_cert.domain_validation_options : option.domain_name => option }

  zone_id = var.hosted_zone_id
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  records = [each.value.resource_record_value]
  ttl     = 60

  depends_on = [aws_acm_certificate.custom_domain_cert]
}

# Validate the ACM Certificate
resource "aws_acm_certificate_validation" "custom_domain_cert_validation" {
  certificate_arn         = aws_acm_certificate.custom_domain_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# Route53 Record for API Gateway Custom Domain
resource "aws_route53_record" "custom_domain" {
  zone_id = var.hosted_zone_id
  name    = var.custom_domain_name
  type    = "A"

  alias {
    name                   = aws_apigatewayv2_domain_name.custom_domain.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.custom_domain.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}
