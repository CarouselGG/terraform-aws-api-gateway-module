# API Gateway
resource "aws_apigatewayv2_api" "api" {
  name          = var.api_name
  protocol_type = "HTTP"
  description   = var.api_description
}

# API Stage
resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = var.api_stage_name
  description = var.api_stage_description
  auto_deploy = true

  default_route_settings {
    detailed_metrics_enabled = true
    throttling_burst_limit   = var.route_throttling_burst_limit
    throttling_rate_limit    = var.route_throttling_rate_limit
  }

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_log_group.arn
    format = jsonencode({
      requestId      = "$context.requestId",
      ip             = "$context.identity.sourceIp",
      user           = "$context.identity.caller",
      requestTime    = "$context.requestTime",
      httpMethod     = "$context.httpMethod",
      routeKey       = "$context.routeKey",
      statusCode     = "$context.status",
      protocol       = "$context.protocol",
      responseLength = "$context.responseLength",
      latency        = "$context.integrationLatency"
    })
  }
}

# Conditionally create API Key and Usage Plan
resource "aws_api_gateway_api_key" "api_key" {
  count       = var.api_key != null ? 1 : 0
  name        = "${var.api_name}-api-key"
  description = "API Key for ${var.api_name}"
  enabled     = true
  value       = var.api_key
}

resource "aws_api_gateway_usage_plan" "usage_plan" {
  count = var.api_key != null ? 1 : 0
  name  = "${var.api_name}-usage-plan"

  throttle_settings {
    burst_limit = var.route_throttling_burst_limit
    rate_limit  = var.route_throttling_rate_limit
  }

  quota_settings {
    limit  = 1000
    period = "MONTH"
  }
}

resource "aws_api_gateway_usage_plan_key" "usage_plan_key" {
  count         = var.api_key != null ? 1 : 0
  key_id        = aws_api_gateway_api_key.api_key[0].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.usage_plan[0].id
}

# Integrations
resource "aws_apigatewayv2_integration" "integrations" {
  for_each = var.routes

  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = each.value.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# Routes with conditional API Key enforcement
resource "aws_apigatewayv2_route" "routes" {
  for_each = aws_apigatewayv2_integration.integrations

  api_id           = aws_apigatewayv2_api.api.id
  route_key        = each.key
  target           = "integrations/${each.value.id}"
  api_key_required = var.api_key != null ? true : false
}

# API Mapping
resource "aws_apigatewayv2_api_mapping" "api_mapping" {
  api_id          = aws_apigatewayv2_api.api.id
  domain_name     = aws_apigatewayv2_domain_name.custom_domain.domain_name
  stage           = aws_apigatewayv2_stage.api_stage.id
  api_mapping_key = var.api_mapping_key
}

resource "aws_lambda_permission" "apigw_lambda_permissions" {
  for_each = var.routes

  statement_id  = "AllowExecution-${substr(md5(each.key), 0, 8)}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*"
}
