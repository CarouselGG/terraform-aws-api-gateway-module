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
  }

  # Access logs configuration
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
      responseLength = "$context.responseLength"
    })
  }
}

# Integrations
resource "aws_apigatewayv2_integration" "integrations" {
  for_each = var.routes

  api_id             = aws_apigatewayv2_api.api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = each.value
  integration_method = "POST"
}

# Routes
resource "aws_apigatewayv2_route" "routes" {
  for_each = aws_apigatewayv2_integration.integrations

  api_id    = aws_apigatewayv2_api.api.id
  route_key = each.key
  target    = "integrations/${each.value.id}"
}

# API Mapping
resource "aws_apigatewayv2_api_mapping" "api_mapping" {
  api_id          = aws_apigatewayv2_api.api.id
  domain_name     = aws_apigatewayv2_domain_name.custom_domain.domain_name
  stage           = aws_apigatewayv2_stage.api_stage.id
  api_mapping_key = var.api_mapping_key
}
