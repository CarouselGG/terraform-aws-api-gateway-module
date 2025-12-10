# =============================================================================
# CloudWatch Dashboard - Combined API Gateway, Routes, and Lambda Metrics
# =============================================================================

locals {
  # Extract unique Lambda function names from routes
  lambda_functions = distinct([for route_key, route in var.routes : route.function_name])

  # Build route keys list for per-route widgets
  route_keys = keys(var.routes)

  # ==========================================================================
  # API Gateway Widgets
  # ==========================================================================

  # Widget 1: Request Volume (stacked area)
  widget_request_volume = {
    type   = "metric"
    x      = 0
    y      = 0
    width  = 12
    height = 6
    properties = {
      metrics = [
        [local.metric_namespace, "TotalRequests", { label = "Total Requests", color = "#1f77b4" }],
        [".", "2xxSuccess", { label = "2xx Success", color = "#2ca02c" }]
      ]
      view    = "timeSeries"
      stacked = true
      region  = var.aws_region
      stat    = "Sum"
      period  = 60
      title   = "API Gateway - Request Volume"
    }
  }

  # Widget 2: Error Rates
  widget_error_rates = {
    type   = "metric"
    x      = 12
    y      = 0
    width  = 12
    height = 6
    properties = {
      metrics = [
        [local.metric_namespace, "3xxErrors", { label = "3xx Redirects", color = "#ff7f0e" }],
        [".", "4xxErrors", { label = "4xx Client Errors", color = "#d62728" }],
        [".", "5xxErrors", { label = "5xx Server Errors", color = "#9467bd" }],
        [".", "OtherErrors", { label = "Other Errors", color = "#8c564b" }]
      ]
      view    = "timeSeries"
      stacked = false
      region  = var.aws_region
      stat    = "Sum"
      period  = 60
      title   = "API Gateway - Error Rates"
    }
  }

  # Widget 3: Latency Percentiles
  widget_latency = {
    type   = "metric"
    x      = 0
    y      = 6
    width  = 12
    height = 6
    properties = {
      metrics = [
        [local.metric_namespace, "Latency", { label = "p50", stat = "p50", color = "#2ca02c" }],
        ["...", { label = "p90", stat = "p90", color = "#ff7f0e" }],
        ["...", { label = "p99", stat = "p99", color = "#d62728" }]
      ]
      view    = "timeSeries"
      stacked = false
      region  = var.aws_region
      period  = 60
      title   = "API Gateway - Latency Percentiles (ms)"
      yAxis = {
        left = { min = 0, label = "Milliseconds" }
      }
    }
  }

  # Widget 4: Success Rate Gauge (fixed formula)
  widget_success_rate = {
    type   = "metric"
    x      = 12
    y      = 6
    width  = 12
    height = 6
    properties = {
      metrics = [
        [{ expression = "IF(m1 > 0, (m2/m1)*100, 100)", label = "Success Rate %", id = "e1", color = "#2ca02c" }],
        [local.metric_namespace, "TotalRequests", { id = "m1", visible = false }],
        [".", "2xxSuccess", { id = "m2", visible = false }]
      ]
      view   = "gauge"
      region = var.aws_region
      stat   = "Sum"
      period = 3600
      title  = "API Gateway - Success Rate (1 hour)"
      yAxis = {
        left = { min = 0, max = 100 }
      }
    }
  }

  # ==========================================================================
  # Per-Route Widgets
  # ==========================================================================

  # Widget 5: Requests by Route
  widget_route_requests = {
    type   = "metric"
    x      = 0
    y      = 12
    width  = 12
    height = 6
    properties = {
      metrics = [
        for route_key in local.route_keys : [local.metric_namespace, "RouteRequests", "Route", route_key, { label = route_key }]
      ]
      view    = "timeSeries"
      stacked = true
      region  = var.aws_region
      stat    = "Sum"
      period  = 60
      title   = "Requests by Route"
    }
  }

  # Widget 6: Latency by Route (p99)
  widget_route_latency = {
    type   = "metric"
    x      = 12
    y      = 12
    width  = 12
    height = 6
    properties = {
      metrics = [
        for route_key in local.route_keys : [local.metric_namespace, "RouteLatency", "Route", route_key, { label = route_key, stat = "p99" }]
      ]
      view    = "timeSeries"
      stacked = false
      region  = var.aws_region
      period  = 60
      title   = "Latency by Route (p99 ms)"
      yAxis = {
        left = { min = 0, label = "Milliseconds" }
      }
    }
  }

  # ==========================================================================
  # Lambda Widgets
  # ==========================================================================

  # Widget 7: Lambda Invocations
  widget_lambda_invocations = {
    type   = "metric"
    x      = 0
    y      = 18
    width  = 12
    height = 6
    properties = {
      metrics = [
        for fn in local.lambda_functions : ["AWS/Lambda", "Invocations", "FunctionName", fn, { label = fn }]
      ]
      view    = "timeSeries"
      stacked = true
      region  = var.aws_region
      stat    = "Sum"
      period  = 60
      title   = "Lambda - Invocations"
    }
  }

  # Widget 8: Lambda Errors
  widget_lambda_errors = {
    type   = "metric"
    x      = 12
    y      = 18
    width  = 12
    height = 6
    properties = {
      metrics = [
        for fn in local.lambda_functions : ["AWS/Lambda", "Errors", "FunctionName", fn, { label = fn }]
      ]
      view    = "timeSeries"
      stacked = false
      region  = var.aws_region
      stat    = "Sum"
      period  = 60
      title   = "Lambda - Errors"
    }
  }

  # Widget 9: Lambda Duration Percentiles
  widget_lambda_duration = {
    type   = "metric"
    x      = 0
    y      = 24
    width  = 12
    height = 6
    properties = {
      metrics = flatten([
        for fn in local.lambda_functions : [
          ["AWS/Lambda", "Duration", "FunctionName", fn, { label = "${fn} p50", stat = "p50" }],
          ["...", { label = "${fn} p99", stat = "p99" }]
        ]
      ])
      view    = "timeSeries"
      stacked = false
      region  = var.aws_region
      period  = 60
      title   = "Lambda - Duration (ms)"
      yAxis = {
        left = { min = 0, label = "Milliseconds" }
      }
    }
  }

  # Widget 10: Lambda Throttles & Concurrent Executions
  widget_lambda_throttles = {
    type   = "metric"
    x      = 12
    y      = 24
    width  = 12
    height = 6
    properties = {
      metrics = flatten([
        [
          for fn in local.lambda_functions : ["AWS/Lambda", "Throttles", "FunctionName", fn, { label = "${fn} Throttles" }]
        ],
        [
          for fn in local.lambda_functions : ["AWS/Lambda", "ConcurrentExecutions", "FunctionName", fn, { label = "${fn} Concurrent", stat = "Maximum", yAxis = "right" }]
        ]
      ])
      view    = "timeSeries"
      stacked = false
      region  = var.aws_region
      stat    = "Sum"
      period  = 60
      title   = "Lambda - Throttles & Concurrent Executions"
      yAxis = {
        left  = { min = 0, label = "Throttles" }
        right = { min = 0, label = "Concurrent" }
      }
    }
  }

  # ==========================================================================
  # Lambda Insights Widgets (conditional)
  # ==========================================================================

  # Widget 11: Lambda Memory Utilization (requires Lambda Insights)
  widget_lambda_memory = {
    type   = "metric"
    x      = 0
    y      = 30
    width  = 12
    height = 6
    properties = {
      metrics = [
        for fn in local.lambda_functions : ["LambdaInsights", "memory_utilization", "function_name", fn, { label = fn }]
      ]
      view    = "timeSeries"
      stacked = false
      region  = var.aws_region
      stat    = "Average"
      period  = 60
      title   = "Lambda - Memory Utilization % (Insights)"
      yAxis = {
        left = { min = 0, max = 100, label = "Percent" }
      }
    }
  }

  # Widget 12: Lambda Cold Starts (requires Lambda Insights)
  widget_lambda_cold_starts = {
    type   = "metric"
    x      = 12
    y      = 30
    width  = 12
    height = 6
    properties = {
      metrics = [
        for fn in local.lambda_functions : ["LambdaInsights", "init_duration", "function_name", fn, { label = fn }]
      ]
      view    = "timeSeries"
      stacked = false
      region  = var.aws_region
      stat    = "Average"
      period  = 60
      title   = "Lambda - Cold Start Duration (Insights)"
      yAxis = {
        left = { min = 0, label = "Milliseconds" }
      }
    }
  }

  # ==========================================================================
  # Assemble Dashboard
  # ==========================================================================

  # Base widgets (always included)
  base_widgets = [
    local.widget_request_volume,
    local.widget_error_rates,
    local.widget_latency,
    local.widget_success_rate,
    local.widget_route_requests,
    local.widget_route_latency,
    local.widget_lambda_invocations,
    local.widget_lambda_errors,
    local.widget_lambda_duration,
    local.widget_lambda_throttles,
  ]

  # Lambda Insights widgets (only if enabled)
  insights_widgets = var.enable_lambda_insights ? [
    local.widget_lambda_memory,
    local.widget_lambda_cold_starts,
  ] : []

  # Combined dashboard widgets
  dashboard_widgets = concat(local.base_widgets, local.insights_widgets)
}

# =============================================================================
# CloudWatch Dashboard Resource
# =============================================================================

resource "aws_cloudwatch_dashboard" "api_gateway_dashboard" {
  count = var.enable_dashboards ? 1 : 0

  dashboard_name = "${var.api_name}-dashboard"
  dashboard_body = jsonencode({
    widgets = local.dashboard_widgets
  })

  depends_on = [
    aws_cloudwatch_log_group.api_gateway_log_group,
    aws_cloudwatch_log_metric_filter.total_requests,
    aws_cloudwatch_log_metric_filter.success_2xx,
    aws_cloudwatch_log_metric_filter.errors_3xx,
    aws_cloudwatch_log_metric_filter.errors_4xx,
    aws_cloudwatch_log_metric_filter.errors_5xx,
    aws_cloudwatch_log_metric_filter.errors_other,
    aws_cloudwatch_log_metric_filter.latency,
    aws_cloudwatch_log_metric_filter.route_requests,
    aws_cloudwatch_log_metric_filter.route_latency,
  ]
}
