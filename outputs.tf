output "api_gateway_invoke_url" {
  description = "Invoke URL of the API Gateway"
  value       = aws_apigatewayv2_stage.api_stage.invoke_url
}

output "custom_domain_name" {
  description = "Custom domain name for the API Gateway"
  value       = aws_apigatewayv2_domain_name.custom_domain.domain_name
}


output "api_id" {
  description = "API Gateway ID"
  value       = aws_apigatewayv2_api.api.id
}

output "stage_name" {
  description = "Stage name of the API Gateway"
  value       = aws_apigatewayv2_stage.api_stage.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch Log Group for API Gateway"
  value       = aws_cloudwatch_log_group.api_gateway_log_group.arn
}

output "log_role_arn" {
  description = "ARN of the IAM Role for API Gateway CloudWatch logging"
  value       = aws_iam_role.api_gateway_cloudwatch_role.arn
}

output "certificate_arn" {
  description = "ARN of the ACM Certificate for the custom domain"
  value       = aws_acm_certificate_validation.custom_domain_cert_validation.certificate_arn
}

output "route53_record_fqdn" {
  description = "FQDN of the Route 53 record for the custom domain"
  value       = aws_route53_record.custom_domain.fqdn
}

output "execution_arn" {
  description = "Execution ARN of the API Gateway"
  value       = aws_apigatewayv2_api.api.execution_arn
}
