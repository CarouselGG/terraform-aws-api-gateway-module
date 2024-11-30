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

resource "aws_cloudwatch_log_metric_filter" "errors_3xx" {
  log_group_name = "/aws/http-api/carousel-rules-api"
  name           = "3xxErrors"
  pattern        = "{ $.statusCode = 3* }"

  metric_transformation {
    name      = "3xxErrors"
    namespace = "API-Gateway-Metrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "errors_4xx" {
  log_group_name = "/aws/http-api/carousel-rules-api"
  name           = "4xxErrors"
  pattern        = "{ $.statusCode = 4* }"

  metric_transformation {
    name      = "4xxErrors"
    namespace = "API-Gateway-Metrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "errors_5xx" {
  log_group_name = "/aws/http-api/carousel-rules-api"
  name           = "5xxErrors"
  pattern        = "{ $.statusCode = 5* }"

  metric_transformation {
    name      = "5xxErrors"
    namespace = "API-Gateway-Metrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "errors_other" {
  log_group_name = "/aws/http-api/carousel-rules-api"
  name           = "OtherErrors"
  pattern        = "{ $.statusCode != 2* && $.statusCode != 3* && $.statusCode != 4* && $.statusCode != 5* }"

  metric_transformation {
    name      = "OtherErrors"
    namespace = "API-Gateway-Metrics"
    value     = "1"
  }
}

