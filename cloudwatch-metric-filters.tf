# Metric Filters for API Gateway Logs
resource "aws_cloudwatch_log_metric_filter" "total_requests" {
  log_group_name = "/aws/http-api/carousel-rules-api"
  name           = "TotalRequests"
  pattern        = ""

  metric_transformation {
    name      = "TotalRequests"
    namespace = "API-Gateway-Metrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "3xx_errors" {
  log_group_name = "/aws/http-api/carousel-rules-api"
  name           = "3xxErrors"
  pattern        = "{ $.statusCode = /^3[0-9]{2}$/ }"

  metric_transformation {
    name      = "3xxErrors"
    namespace = "API-Gateway-Metrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "4xx_errors" {
  log_group_name = "/aws/http-api/carousel-rules-api"
  name           = "4xxErrors"
  pattern        = "{ $.statusCode = /^4[0-9]{2}$/ }"

  metric_transformation {
    name      = "4xxErrors"
    namespace = "API-Gateway-Metrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "5xx_errors" {
  log_group_name = "/aws/http-api/carousel-rules-api"
  name           = "5xxErrors"
  pattern        = "{ $.statusCode = /^5[0-9]{2}$/ }"

  metric_transformation {
    name      = "5xxErrors"
    namespace = "API-Gateway-Metrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "other_errors" {
  log_group_name = "/aws/http-api/carousel-rules-api"
  name           = "OtherErrors"
  pattern        = "{ $.statusCode != /^2[0-9]{2}$/ && $.statusCode != /^3[0-9]{2}$/ && $.statusCode != /^4[0-9]{2}$/ && $.statusCode != /^5[0-9]{2}$/ }"

  metric_transformation {
    name      = "OtherErrors"
    namespace = "API-Gateway-Metrics"
    value     = "1"
  }
}
