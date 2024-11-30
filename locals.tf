locals {
  metric_namespace  = "AWS/ApiGateway"
  log_group_name    = var.log_group_name != null ? var.log_group_name : "/aws/http-api/${var.api_name}"
  cloudwatch_source = aws_cloudwatch_log_group.api_gateway_log_group.name
}
