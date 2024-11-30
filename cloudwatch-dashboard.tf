# resource "aws_cloudwatch_dashboard" "api_gateway_dashboard" {
#   count = var.enable_dashboards ? 1 : 0

#   dashboard_name = "${var.api_name}-dashboard"

#   dashboard_body = jsonencode({
#     widgets = [

#       # Overall Traffic and Status Codes Widget (First Line)
#       {
#         type   = "metric"
#         x      = 0
#         y      = 0
#         width  = 24
#         height = 6
#         properties = {
#           view   = "timeSeries"
#           title  = "Overall Traffic and Status Codes"
#           region = var.aws_region
#           metrics = [
#             [local.metric_namespace, "Count", "ApiName", var.api_name, "Stage", var.api_stage_name, { "stat" : "Sum", "color" : "#800080" }],    # Total Calls (Purple)
#             [local.metric_namespace, "4xxError", "ApiName", var.api_name, "Stage", var.api_stage_name, { "stat" : "Sum", "color" : "#FFD700" }], # 400 Errors (Yellow)
#             [local.metric_namespace, "5xxError", "ApiName", var.api_name, "Stage", var.api_stage_name, { "stat" : "Sum", "color" : "#FF0000" }], # 500 Errors (Red)
#             [local.metric_namespace, "2xx", "ApiName", var.api_name, "Stage", var.api_stage_name, { "stat" : "Sum", "color" : "#008000" }]       # Successful 200 Responses (Green)
#           ]
#           period = 300
#           stat   = "Sum"
#         }
#       },

#       # 4xx Errors Widget (Second Line)
#       {
#         type   = "metric"
#         x      = 0
#         y      = 6
#         width  = 12
#         height = 6
#         properties = {
#           view   = "timeSeries"
#           title  = "4xx Errors"
#           region = var.aws_region
#           metrics = [
#             [local.metric_namespace, "4xxError", "ApiName", var.api_name, "Stage", var.api_stage_name, { "stat" : "Sum" }]
#           ]
#           period = 300
#           stat   = "Sum"
#           annotations = {
#             horizontal = [
#               {
#                 value = 0
#                 label = "Baseline"
#                 color = "#ff0000"
#               }
#             ]
#           }
#         }
#       },

#       # 5xx Errors Widget (Second Line)
#       {
#         type   = "metric"
#         x      = 12
#         y      = 6
#         width  = 12
#         height = 6
#         properties = {
#           view   = "timeSeries"
#           title  = "5xx Errors"
#           region = var.aws_region
#           metrics = [
#             [local.metric_namespace, "5xxError", "ApiName", var.api_name, "Stage", var.api_stage_name, { "stat" : "Sum" }]
#           ]
#           period = 300
#           stat   = "Sum"
#           annotations = {
#             horizontal = [
#               {
#                 value = 0
#                 label = "Baseline"
#                 color = "#ff0000"
#               }
#             ]
#           }
#         }
#       },

#       # Integration Latency Widget (Third Line)
#       {
#         type   = "metric"
#         x      = 0
#         y      = 12
#         width  = 12
#         height = 6
#         properties = {
#           view   = "timeSeries"
#           title  = "Integration Latency"
#           region = var.aws_region
#           metrics = [
#             [local.metric_namespace, "IntegrationLatency", "ApiName", var.api_name, "Stage", var.api_stage_name, { "stat" : "Average" }]
#           ]
#           period = 300
#           stat   = "Average"
#         }
#       },

#       # Overall Latency Widget (Third Line)
#       {
#         type   = "metric"
#         x      = 12
#         y      = 12
#         width  = 12
#         height = 6
#         properties = {
#           view   = "timeSeries"
#           title  = "Overall Latency"
#           region = var.aws_region
#           metrics = [
#             [local.metric_namespace, "Latency", "ApiName", var.api_name, "Stage", var.api_stage_name, { "stat" : "Average" }]
#           ]
#           period = 300
#           stat   = "Average"
#         }
#       },

#       # Latency Percentiles Widget (Fourth Line)
#       {
#         type   = "metric"
#         x      = 0
#         y      = 18
#         width  = 12
#         height = 6
#         properties = {
#           view   = "timeSeries"
#           title  = "Latency Percentiles (P50, P90, P99)"
#           region = var.aws_region
#           metrics = [
#             [local.metric_namespace, "Latency", "ApiName", var.api_name, "Stage", var.api_stage_name, { "stat" : "p50" }],
#             [local.metric_namespace, "Latency", "ApiName", var.api_name, "Stage", var.api_stage_name, { "stat" : "p90" }],
#             [local.metric_namespace, "Latency", "ApiName", var.api_name, "Stage", var.api_stage_name, { "stat" : "p99" }]
#           ]
#           period = 300
#         }
#       },

#       # Latency Comparison Widget (Fourth Line)
#       {
#         type   = "metric"
#         x      = 12
#         y      = 18
#         width  = 12
#         height = 6
#         properties = {
#           view   = "timeSeries"
#           title  = "Latency Comparison (Overall vs. Integration)"
#           region = var.aws_region
#           metrics = [
#             [local.metric_namespace, "Latency", "ApiName", var.api_name, "Stage", var.api_stage_name, { "stat" : "Average" }],
#             [local.metric_namespace, "IntegrationLatency", "ApiName", var.api_name, "Stage", var.api_stage_name, { "stat" : "Average" }]
#           ]
#           period = 300
#         }
#       }
#     ]
#   })
# }
