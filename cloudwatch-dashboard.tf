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
            ["API-Gateway-Metrics", "TotalRequests"],
            [".", aws_cloudwatch_log_metric_filter.errors_3xx.name],
            [".", aws_cloudwatch_log_metric_filter.errors_4xx.name],
            [".", aws_cloudwatch_log_metric_filter.errors_5xx.name],
            [".", aws_cloudwatch_log_metric_filter.errors_other.name]
          ],
          "view" : "timeSeries",
          "stacked" : false,
          "region" : "${var.aws_region}",
          "stat" : "Sum",
          "period" : 300,
          "title" : "API Gateway Requests and Errors"
        }
      },

      // Metric showing current average latency with p99 in single value view
      {
        "type" : "metric",
        "x" : 0,
        "y" : 6,
        "width" : 12,
        "height" : 6,
        "properties" : {
          "metrics" : [
            [
              "AWS/ApiGateway",
              "Latency",
              "ApiName",
              "${var.api_name}",
              "Stage",
              "v1",
              { "region" : "${var.aws_region}" }
            ]
          ],
          "region" : "${var.aws_region}",
          "stat" : "p99",
          "title" : "Latency",
          "view" : "singleValue",
          "period" : 300
        }
      },

      // Success Rate metric that uses a guage view to compare 2xx to 5xx errors. should be green for 2xx and red for 5xx
      {
        "type" : "metric",
        "x" : 12,
        "y" : 6,
        "width" : 12,
        "height" : 6,
        "properties" : {
          "metrics" : [
            ["API-Gateway-Metrics", aws_cloudwatch_log_metric_filter.errors_5xx.name],
            ["API-Gateway-Metrics", aws_cloudwatch_log_metric_filter.success_2xx.name]
          ],
          "view" : "gauge",
          "stacked" : false,
          "region" : "${var.aws_region}",
          "stat" : "Average",
          "period" : 300,
          "title" : "Success Rate",
          "yAxis" : {
            "left" : {
              "min" : 0,
              "max" : 100
            }
          }
        }
      },
    ]
  })
}
