resource "aws_cloudwatch_dashboard" "api_gateway_dashboard" {
  count = var.enable_dashboards ? 1 : 0

  dashboard_name = "${var.api_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      # 4xx Errors Widget
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          view  = "timeSeries"
          title = "4xx Errors"
          metrics = [
            ["AWS/ApiGateway", "4xxError", "ApiName", var.api_name, { "stat" : "Sum" }]
          ]
          period = 300
          stat   = "Sum"
          annotations = {
            horizontal = [
              {
                value = 0
                label = "Baseline"
                color = "#ff0000"
              }
            ]
          }
        }
      },

      # 5xx Errors Widget
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          view  = "timeSeries"
          title = "5xx Errors"
          metrics = [
            ["AWS/ApiGateway", "5xxError", "ApiName", var.api_name, { "stat" : "Sum" }]
          ]
          period = 300
          stat   = "Sum"
          annotations = {
            horizontal = [
              {
                value = 0
                label = "Baseline"
                color = "#ff0000"
              }
            ]
          }
        }
      },

      # Integration Latency Widget
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          view  = "timeSeries"
          title = "Integration Latency"
          metrics = [
            ["AWS/ApiGateway", "IntegrationLatency", "ApiName", var.api_name, { "stat" : "Average" }]
          ]
          period = 300
          stat   = "Average"
        }
      },

      # Overall Latency Widget
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          view  = "timeSeries"
          title = "Overall Latency"
          metrics = [
            ["AWS/ApiGateway", "Latency", "ApiName", var.api_name, { "stat" : "Average" }]
          ]
          period = 300
          stat   = "Average"
        }
      }
    ]
  })
}
