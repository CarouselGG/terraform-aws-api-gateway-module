# CloudWatch Dashboard with Line Chart Widgets
resource "aws_cloudwatch_dashboard" "api_gateway_dashboard" {
  count = var.enable_dashboards ? 1 : 0

  dashboard_name = "${var.api_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        "type" : "metric",
        "x" : 0,
        "y" : 0,
        "width" : 24,
        "height" : 6,
        "properties" : {
          "metrics" : [
            [local.metric_namespace, "TotalRequests"],
            [".", aws_cloudwatch_log_metric_filter.errors_3xx.name],
            [".", aws_cloudwatch_log_metric_filter.errors_4xx.name],
            [".", aws_cloudwatch_log_metric_filter.errors_5xx.name],
            [".", aws_cloudwatch_log_metric_filter.errors_other.name]
          ],
          "view" : "timeSeries",
          "stacked" : false,
          "region" : var.aws_region,
          "stat" : "Sum",
          "period" : 300,
          "title" : "API Gateway Requests and Errors"
        }
      },

      // Average Latency
      {
        "type" : "metric",
        "x" : 0,
        "y" : 6,
        "width" : 24,
        "height" : 6,
        "properties" : {
          "metrics" : [
            ["AWS/ApiGateway", "Latency", "ApiName", var.api_name, "Stage", var.api_stage_name, { "region" : var.aws_region }]
          ],
          "view" : "timeSeries",
          "stacked" : false,
          "region" : var.aws_region,
          "stat" : "Average",
          "period" : 360,
          "title" : "API Gateway Latency"
        }
      },

      // Success Rate
      {
        "type" : "metric",
        "x" : 0,
        "y" : 12,
        "width" : 24,
        "height" : 6,
        "properties" : {
          "metrics" : [
            [{ "color" : "#2ca02c", "expression" : "(1 - (m1/m2))*100", "id" : "e1", "label" : "Success Rate", "region" : var.aws_region }],
            [local.metric_namespace, aws_cloudwatch_log_metric_filter.success_2xx.name, { "id" : "m2", "visible" : false, "region" : var.aws_region }],
            [".", aws_cloudwatch_log_metric_filter.errors_5xx.name, { "id" : "m1", "visible" : false, "region" : var.aws_region }]
          ],
          "view" : "guage",
          "region" : var.aws_region,
          "stat" : "Sum",
          "period" : 3600,
          "title" : "Success Rate"
        }
      }
    ]
  })
}
