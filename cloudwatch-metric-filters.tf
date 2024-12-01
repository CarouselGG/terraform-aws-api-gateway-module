# Total Requests
resource "aws_cloudwatch_log_metric_filter" "total_requests" {
  count = var.enable_dashboards ? 1 : 0

  log_group_name = "/aws/http-api/carousel-rules-api"
  name           = "TotalRequests"
  pattern        = "{ $.httpMethod = * }"

  metric_transformation {
    name      = "TotalRequests"
    namespace = local.metric_namespace
    value     = "1"
  }

  depends_on = [
    aws_cloudwatch_log_group.api_gateway_log_group,
  ]
}

# 2xx Success
resource "aws_cloudwatch_log_metric_filter" "success_2xx" {
  count = var.enable_dashboards ? 1 : 0

  log_group_name = "/aws/http-api/carousel-rules-api"
  name           = "2xxSuccess"
  pattern        = "{ $.statusCode >= 200 && $.statusCode < 300 }"

  metric_transformation {
    name      = "2xxSuccess"
    namespace = local.metric_namespace
    value     = "1"
  }

  depends_on = [
    aws_cloudwatch_log_group.api_gateway_log_group,
  ]
}

# 3xx Redirects
resource "aws_cloudwatch_log_metric_filter" "errors_3xx" {
  count = var.enable_dashboards ? 1 : 0

  log_group_name = "/aws/http-api/carousel-rules-api"
  name           = "3xxErrors"
  pattern        = "{ $.statusCode >= 300 && $.statusCode < 400 }"

  metric_transformation {
    name      = "3xxErrors"
    namespace = local.metric_namespace
    value     = "1"
  }

  depends_on = [
    aws_cloudwatch_log_group.api_gateway_log_group,
  ]
}

# 4xx Client Errors
resource "aws_cloudwatch_log_metric_filter" "errors_4xx" {
  count = var.enable_dashboards ? 1 : 0

  log_group_name = "/aws/http-api/carousel-rules-api"
  name           = "4xxErrors"
  pattern        = "{ $.statusCode >= 400 && $.statusCode < 500 }"

  metric_transformation {
    name      = "4xxErrors"
    namespace = local.metric_namespace
    value     = "1"
  }

  depends_on = [
    aws_cloudwatch_log_group.api_gateway_log_group,
  ]
}

# 5xx Server Errors
resource "aws_cloudwatch_log_metric_filter" "errors_5xx" {
  count = var.enable_dashboards ? 1 : 0

  log_group_name = "/aws/http-api/carousel-rules-api"
  name           = "5xxErrors"
  pattern        = "{ $.statusCode >= 500 && $.statusCode < 600 }"

  metric_transformation {
    name      = "5xxErrors"
    namespace = local.metric_namespace
    value     = "1"
  }

  depends_on = [
    aws_cloudwatch_log_group.api_gateway_log_group,
  ]
}

# Other Errors
resource "aws_cloudwatch_log_metric_filter" "errors_other" {
  count = var.enable_dashboards ? 1 : 0

  log_group_name = "/aws/http-api/carousel-rules-api"
  name           = "OtherErrors"
  pattern        = "{ $.statusCode < 200 || $.statusCode >= 600 }"

  metric_transformation {
    name      = "OtherErrors"
    namespace = local.metric_namespace
    value     = "1"
  }

  depends_on = [
    aws_cloudwatch_log_group.api_gateway_log_group,
  ]
}

# Latency P99
resource "aws_cloudwatch_log_metric_filter" "latency_p99" {
  count = var.enable_dashboards ? 1 : 0

  log_group_name = "/aws/http-api/carousel-rules-api"
  name           = "LatencyP99"
  pattern        = "{ $.latency = * }"

  metric_transformation {
    name      = "LatencyP99"
    namespace = local.metric_namespace
    value     = "$.latency"
  }

  depends_on = [
    aws_cloudwatch_log_group.api_gateway_log_group,
  ]
}
