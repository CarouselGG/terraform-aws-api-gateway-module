# =============================================================================
# Aggregate API Gateway Metric Filters
# =============================================================================

# Total Requests
resource "aws_cloudwatch_log_metric_filter" "total_requests" {
  count = var.enable_dashboards ? 1 : 0

  log_group_name = local.log_group_name
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

  log_group_name = local.log_group_name
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

  log_group_name = local.log_group_name
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

  log_group_name = local.log_group_name
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

  log_group_name = local.log_group_name
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

  log_group_name = local.log_group_name
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

# Latency (extracts actual latency value for percentile calculations)
resource "aws_cloudwatch_log_metric_filter" "latency" {
  count = var.enable_dashboards ? 1 : 0

  log_group_name = local.log_group_name
  name           = "Latency"
  pattern        = "{ $.latency = * }"

  metric_transformation {
    name      = "Latency"
    namespace = local.metric_namespace
    value     = "$.latency"
    unit      = "Milliseconds"
  }

  depends_on = [
    aws_cloudwatch_log_group.api_gateway_log_group,
  ]
}

# =============================================================================
# Per-Route Metric Filters (using dimensions to separate by route)
# =============================================================================
# These filters use a single filter with dimensions instead of one filter per route,
# which avoids hitting the CloudWatch 100 metric filters per log group limit.

# Per-Route Request Count
resource "aws_cloudwatch_log_metric_filter" "route_requests" {
  count = var.enable_dashboards ? 1 : 0

  log_group_name = local.log_group_name
  name           = "RouteRequests"
  pattern        = "{ $.routeKey = * }"

  metric_transformation {
    name      = "RouteRequests"
    namespace = local.metric_namespace
    value     = "1"
    dimensions = {
      Route = "$.routeKey"
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.api_gateway_log_group,
  ]
}

# Per-Route 4xx Errors
resource "aws_cloudwatch_log_metric_filter" "route_errors_4xx" {
  count = var.enable_dashboards ? 1 : 0

  log_group_name = local.log_group_name
  name           = "Route4xxErrors"
  pattern        = "{ $.routeKey = * && $.statusCode >= 400 && $.statusCode < 500 }"

  metric_transformation {
    name      = "Route4xxErrors"
    namespace = local.metric_namespace
    value     = "1"
    dimensions = {
      Route = "$.routeKey"
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.api_gateway_log_group,
  ]
}

# Per-Route 5xx Errors
resource "aws_cloudwatch_log_metric_filter" "route_errors_5xx" {
  count = var.enable_dashboards ? 1 : 0

  log_group_name = local.log_group_name
  name           = "Route5xxErrors"
  pattern        = "{ $.routeKey = * && $.statusCode >= 500 && $.statusCode < 600 }"

  metric_transformation {
    name      = "Route5xxErrors"
    namespace = local.metric_namespace
    value     = "1"
    dimensions = {
      Route = "$.routeKey"
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.api_gateway_log_group,
  ]
}

# Per-Route Latency
resource "aws_cloudwatch_log_metric_filter" "route_latency" {
  count = var.enable_dashboards ? 1 : 0

  log_group_name = local.log_group_name
  name           = "RouteLatency"
  pattern        = "{ $.routeKey = * && $.latency = * }"

  metric_transformation {
    name      = "RouteLatency"
    namespace = local.metric_namespace
    value     = "$.latency"
    unit      = "Milliseconds"
    dimensions = {
      Route = "$.routeKey"
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.api_gateway_log_group,
  ]
}
