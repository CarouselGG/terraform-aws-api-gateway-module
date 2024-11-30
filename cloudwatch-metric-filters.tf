# Total Requests
resource "aws_cloudwatch_log_metric_filter" "total_requests" {
  log_group_name = "/aws/http-api/carousel-rules-api"
  name           = "TotalRequests"
  pattern        = "{ $.httpMethod = * }"

  metric_transformation {
    name      = "TotalRequests"
    namespace = "API-Gateway-Metrics"
    value     = "1"
  }
}

# 2xx Errors
resource "aws_cloudwatch_log_metric_filter" "success_2xx" {
  log_group_name = "/aws/http-api/carousel-rules-api"
  name           = "2xxSuccess"
  pattern        = "{ $.statusCode =~ /^2[0-9][0-9]$/ }"

  metric_transformation {
    name      = "2xxSuccess"
    namespace = "API-Gateway-Metrics"
    value     = "1"
  }
}

# 3xx Errors
resource "aws_cloudwatch_log_metric_filter" "errors_3xx" {
  log_group_name = "/aws/http-api/carousel-rules-api"
  name           = "3xxErrors"
  pattern        = "{ $.statusCode =~ /^3[0-9][0-9]$/ }"

  metric_transformation {
    name      = "3xxErrors"
    namespace = "API-Gateway-Metrics"
    value     = "1"
  }
}

# 4xx Errors
resource "aws_cloudwatch_log_metric_filter" "errors_4xx" {
  log_group_name = "/aws/http-api/carousel-rules-api"
  name           = "4xxErrors"
  pattern        = "{ $.statusCode =~ /^4[0-9][0-9]$/ }"

  metric_transformation {
    name      = "4xxErrors"
    namespace = "API-Gateway-Metrics"
    value     = "1"
  }
}

# 5xx Errors
resource "aws_cloudwatch_log_metric_filter" "errors_5xx" {
  log_group_name = "/aws/http-api/carousel-rules-api"
  name           = "5xxErrors"
  pattern        = "{ $.statusCode =~ /^5[0-9][0-9]$/ }"

  metric_transformation {
    name      = "5xxErrors"
    namespace = "API-Gateway-Metrics"
    value     = "1"
  }
}

# Other Errors
resource "aws_cloudwatch_log_metric_filter" "errors_other" {
  log_group_name = "/aws/http-api/carousel-rules-api"
  name           = "OtherErrors"
  pattern        = "{ $.statusCode != /^2[0-9][0-9]$/ && $.statusCode != /^3[0-9][0-9]$/ && $.statusCode != /^4[0-9][0-9]$/ && $.statusCode != /^5[0-9][0-9]$/ }"

  metric_transformation {
    name      = "OtherErrors"
    namespace = "API-Gateway-Metrics"
    value     = "1"
  }
}
