locals {
  metric_namespace = var.api_name
}

# Total Requests
resource "aws_cloudwatch_log_metric_filter" "total_requests" {
  log_group_name = "/aws/http-api/carousel-rules-api"
  name           = "TotalRequests"
  pattern        = "{ $.httpMethod = * }"

  metric_transformation {
    name      = "TotalRequests"
    namespace = local.metric_namespace
    value     = "1"
  }
}

# 2xx Success
resource "aws_cloudwatch_log_metric_filter" "success_2xx" {
  log_group_name = "/aws/http-api/carousel-rules-api"
  name           = "2xxSuccess"
  pattern        = "{ $.statusCode >= 200 && $.statusCode < 300 }"

  metric_transformation {
    name      = "2xxSuccess"
    namespace = local.metric_namespace
    value     = "1"
  }
}

# 3xx Redirects
resource "aws_cloudwatch_log_metric_filter" "errors_3xx" {
  log_group_name = "/aws/http-api/carousel-rules-api"
  name           = "3xxErrors"
  pattern        = "{ $.statusCode >= 300 && $.statusCode < 400 }"

  metric_transformation {
    name      = "3xxErrors"
    namespace = local.metric_namespace
    value     = "1"
  }
}

# 4xx Client Errors
resource "aws_cloudwatch_log_metric_filter" "errors_4xx" {
  log_group_name = "/aws/http-api/carousel-rules-api"
  name           = "4xxErrors"
  pattern        = "{ $.statusCode >= 400 && $.statusCode < 500 }"

  metric_transformation {
    name      = "4xxErrors"
    namespace = local.metric_namespace
    value     = "1"
  }
}

# 5xx Server Errors
resource "aws_cloudwatch_log_metric_filter" "errors_5xx" {
  log_group_name = "/aws/http-api/carousel-rules-api"
  name           = "5xxErrors"
  pattern        = "{ $.statusCode >= 500 && $.statusCode < 600 }"

  metric_transformation {
    name      = "5xxErrors"
    namespace = local.metric_namespace
    value     = "1"
  }
}

# Other Errors
resource "aws_cloudwatch_log_metric_filter" "errors_other" {
  log_group_name = "/aws/http-api/carousel-rules-api"
  name           = "OtherErrors"
  pattern        = "{ $.statusCode < 200 || $.statusCode >= 600 }"

  metric_transformation {
    name      = "OtherErrors"
    namespace = local.metric_namespace
    value     = "1"
  }
}

# Latency P99
resource "aws_cloudwatch_log_metric_filter" "latency_p99" {
  log_group_name = "/aws/http-api/carousel-rules-api"
  name           = "LatencyP99"
  pattern        = "{ $.latency = * }"

  metric_transformation {
    name      = "LatencyP99"
    namespace = local.metric_namespace
    value     = "$.latency"
  }
}
