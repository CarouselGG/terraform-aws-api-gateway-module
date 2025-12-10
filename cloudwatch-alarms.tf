# =============================================================================
# CloudWatch Alarms - API Gateway and Lambda Monitoring
# =============================================================================

# =============================================================================
# SNS Topic (Optional)
# =============================================================================

resource "aws_sns_topic" "alarms" {
  count = var.enable_alarms && var.create_sns_topic ? 1 : 0

  name = coalesce(var.sns_topic_name, "${var.api_name}-alarms")

  tags = {
    Name      = coalesce(var.sns_topic_name, "${var.api_name}-alarms")
    ApiName   = var.api_name
    ManagedBy = "terraform"
  }
}

locals {
  # Determine the SNS topic ARN to use (created or provided)
  sns_topic_arn = var.create_sns_topic ? (
    length(aws_sns_topic.alarms) > 0 ? aws_sns_topic.alarms[0].arn : null
  ) : var.alarm_sns_topic_arn

  # Only create alarms if enabled and we have an SNS topic (either created or provided)
  create_alarms = var.enable_alarms && local.sns_topic_arn != null
}

# =============================================================================
# API Gateway Alarms
# =============================================================================

# API Gateway 5xx Error Rate Alarm
resource "aws_cloudwatch_metric_alarm" "api_5xx_error_rate" {
  count = local.create_alarms ? 1 : 0

  alarm_name          = "${var.api_name}-5xx-error-rate"
  alarm_description   = "API Gateway 5xx error rate exceeds ${var.alarm_thresholds.error_rate_percent}%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  threshold           = var.alarm_thresholds.error_rate_percent

  metric_query {
    id          = "error_rate"
    expression  = "IF(requests > 0, (errors / requests) * 100, 0)"
    label       = "5xx Error Rate"
    return_data = true
  }

  metric_query {
    id = "errors"
    metric {
      metric_name = "5xxErrors"
      namespace   = local.metric_namespace
      period      = 300
      stat        = "Sum"
    }
  }

  metric_query {
    id = "requests"
    metric {
      metric_name = "TotalRequests"
      namespace   = local.metric_namespace
      period      = 300
      stat        = "Sum"
    }
  }

  alarm_actions             = [local.sns_topic_arn]
  ok_actions                = [local.sns_topic_arn]
  insufficient_data_actions = []

  tags = {
    Name      = "${var.api_name}-5xx-error-rate"
    ApiName   = var.api_name
    ManagedBy = "terraform"
  }

  depends_on = [
    aws_cloudwatch_log_metric_filter.errors_5xx,
    aws_cloudwatch_log_metric_filter.total_requests,
  ]
}

# API Gateway P99 Latency Alarm
resource "aws_cloudwatch_metric_alarm" "api_p99_latency" {
  count = local.create_alarms ? 1 : 0

  alarm_name          = "${var.api_name}-p99-latency"
  alarm_description   = "API Gateway P99 latency exceeds ${var.alarm_thresholds.p99_latency_ms}ms"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "Latency"
  namespace           = local.metric_namespace
  period              = 300
  extended_statistic  = "p99"
  threshold           = var.alarm_thresholds.p99_latency_ms
  treat_missing_data  = "notBreaching"

  alarm_actions             = [local.sns_topic_arn]
  ok_actions                = [local.sns_topic_arn]
  insufficient_data_actions = []

  tags = {
    Name      = "${var.api_name}-p99-latency"
    ApiName   = var.api_name
    ManagedBy = "terraform"
  }

  depends_on = [
    aws_cloudwatch_log_metric_filter.latency,
  ]
}

# API Gateway 4xx Error Rate Alarm (client errors - informational)
resource "aws_cloudwatch_metric_alarm" "api_4xx_error_rate" {
  count = local.create_alarms ? 1 : 0

  alarm_name          = "${var.api_name}-4xx-error-rate"
  alarm_description   = "API Gateway 4xx client error rate is elevated (informational)"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  threshold           = 20 # 20% - higher threshold for client errors

  metric_query {
    id          = "error_rate"
    expression  = "IF(requests > 0, (errors / requests) * 100, 0)"
    label       = "4xx Error Rate"
    return_data = true
  }

  metric_query {
    id = "errors"
    metric {
      metric_name = "4xxErrors"
      namespace   = local.metric_namespace
      period      = 300
      stat        = "Sum"
    }
  }

  metric_query {
    id = "requests"
    metric {
      metric_name = "TotalRequests"
      namespace   = local.metric_namespace
      period      = 300
      stat        = "Sum"
    }
  }

  alarm_actions             = [local.sns_topic_arn]
  ok_actions                = [local.sns_topic_arn]
  insufficient_data_actions = []

  tags = {
    Name      = "${var.api_name}-4xx-error-rate"
    ApiName   = var.api_name
    ManagedBy = "terraform"
  }

  depends_on = [
    aws_cloudwatch_log_metric_filter.errors_4xx,
    aws_cloudwatch_log_metric_filter.total_requests,
  ]
}

# =============================================================================
# Lambda Alarms (per function)
# =============================================================================

# Lambda Error Rate Alarm (per function)
resource "aws_cloudwatch_metric_alarm" "lambda_error_rate" {
  for_each = local.create_alarms ? toset(local.lambda_functions) : toset([])

  alarm_name          = "${each.value}-error-rate"
  alarm_description   = "Lambda function ${each.value} error rate exceeds ${var.alarm_thresholds.lambda_error_percent}%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  threshold           = var.alarm_thresholds.lambda_error_percent

  metric_query {
    id          = "error_rate"
    expression  = "IF(invocations > 0, (errors / invocations) * 100, 0)"
    label       = "Error Rate"
    return_data = true
  }

  metric_query {
    id = "errors"
    metric {
      metric_name = "Errors"
      namespace   = "AWS/Lambda"
      period      = 300
      stat        = "Sum"
      dimensions = {
        FunctionName = each.value
      }
    }
  }

  metric_query {
    id = "invocations"
    metric {
      metric_name = "Invocations"
      namespace   = "AWS/Lambda"
      period      = 300
      stat        = "Sum"
      dimensions = {
        FunctionName = each.value
      }
    }
  }

  alarm_actions             = [local.sns_topic_arn]
  ok_actions                = [local.sns_topic_arn]
  insufficient_data_actions = []

  tags = {
    Name         = "${each.value}-error-rate"
    FunctionName = each.value
    ApiName      = var.api_name
    ManagedBy    = "terraform"
  }
}

# Lambda Throttle Alarm (per function)
resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  for_each = local.create_alarms ? toset(local.lambda_functions) : toset([])

  alarm_name          = "${each.value}-throttles"
  alarm_description   = "Lambda function ${each.value} is being throttled (>${var.alarm_thresholds.lambda_throttle_count} throttles)"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = var.alarm_thresholds.lambda_throttle_count
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = each.value
  }

  alarm_actions             = [local.sns_topic_arn]
  ok_actions                = [local.sns_topic_arn]
  insufficient_data_actions = []

  tags = {
    Name         = "${each.value}-throttles"
    FunctionName = each.value
    ApiName      = var.api_name
    ManagedBy    = "terraform"
  }
}

# Lambda Duration Alarm (per function) - warns when approaching timeout
# Uses 80% of a typical Lambda timeout (assuming 30s default)
resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  for_each = local.create_alarms ? toset(local.lambda_functions) : toset([])

  alarm_name          = "${each.value}-high-duration"
  alarm_description   = "Lambda function ${each.value} P99 duration is high (may approach timeout)"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = 300
  extended_statistic  = "p99"
  threshold           = 24000 # 24 seconds (80% of 30s timeout)
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = each.value
  }

  alarm_actions             = [local.sns_topic_arn]
  ok_actions                = [local.sns_topic_arn]
  insufficient_data_actions = []

  tags = {
    Name         = "${each.value}-high-duration"
    FunctionName = each.value
    ApiName      = var.api_name
    ManagedBy    = "terraform"
  }
}

# Lambda Concurrent Executions Alarm (per function)
resource "aws_cloudwatch_metric_alarm" "lambda_concurrent_executions" {
  for_each = local.create_alarms ? toset(local.lambda_functions) : toset([])

  alarm_name          = "${each.value}-high-concurrency"
  alarm_description   = "Lambda function ${each.value} concurrent executions are high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "ConcurrentExecutions"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Maximum"
  threshold           = 100 # Alert when approaching default concurrency limit
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = each.value
  }

  alarm_actions             = [local.sns_topic_arn]
  ok_actions                = [local.sns_topic_arn]
  insufficient_data_actions = []

  tags = {
    Name         = "${each.value}-high-concurrency"
    FunctionName = each.value
    ApiName      = var.api_name
    ManagedBy    = "terraform"
  }
}
