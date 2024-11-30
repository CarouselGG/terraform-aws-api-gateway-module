resource "aws_cloudwatch_dashboard" "api_gateway_dashboard2" {
  count = var.enable_dashboards ? 1 : 0

  dashboard_name = "${var.api_name}-dashboard-2"

  dashboard_body = jsonencode({

    "start" : "-PT6H",
    "widgets" : [
      {
        "height" : 1,
        "width" : 24,
        "y" : 0,
        "x" : 0,
        "type" : "text",
        "properties" : {
          "markdown" : "# Service Level Summary"
        }
      },
      {
        "height" : 6,
        "width" : 12,
        "y" : 1,
        "x" : 0,
        "type" : "log",
        "properties" : {
          "query" : "SOURCE '${local.cloudwatch_source}' | fields @timestamp, @message\n| stats sum(status like /^2\\d{2}$/) as OK, sum(status like /^3\\d{2}$/) as Redirects, sum(status like /^4\\d{2}$/) as BadRequests, sum(status like /^5\\d{2}$/) as Errors  by bin(1h) as SampleRate\n | sort SampleRate asc\n",
          "region" : "${var.aws_region}",
          "title" : "Status codes over Time",
          "view" : "bar"
        }
      },
      {
        "height" : 6,
        "width" : 12,
        "y" : 1,
        "x" : 12,
        "type" : "log",
        "properties" : {
          "query" : "SOURCE '${local.cloudwatch_source}' | fields @timestamp, @message\n| stats sum(status like /^5\\d{2}$/) as Errors by bin(1h) as SampleRate \n | sort SampleRate asc\n",
          "region" : "${var.aws_region}",
          "title" : "Errors over time",
          "view" : "bar"
        }
      },
      {
        "height" : 6,
        "width" : 12,
        "y" : 7,
        "x" : 0,
        "type" : "metric",
        "properties" : {
          "metrics" : [
            ["AWS/ApiGateway", "Latency", "ApiName", "${var.api_name}", "Stage", "v1"]
          ],
          "region" : "${var.aws_region}",
          "stat" : "p99",
          "title" : "Latency",
          "view" : "singleValue"
        }
      },
      {
        "height" : 6,
        "width" : 12,
        "y" : 7,
        "x" : 12,
        "type" : "metric",
        "properties" : {
          "metrics" : [
            [{ "color" : "#2ca02c", "expression" : "(1 - (m1/m2))*100", "id" : "e1", "label" : "Success Rate" }],
            ["HttpApi/${var.api_name}", "Status 200", { "id" : "m2", "visible" : false }],
            [".", "HTTP-500-count", { "id" : "m1", "visible" : false }]
          ],
          "region" : "${var.aws_region}",
          "stat" : "Sum",
          "title" : "Success Rate",
          "view" : "gauge",
          "yAxis" : {
            "left" : {
              "max" : 100,
              "min" : 0
            }
          }
        }
      },
      {
        "height" : 6,
        "width" : 24,
        "y" : 13,
        "x" : 0,
        "type" : "log",
        "properties" : {
          "query" : "SOURCE '${local.cloudwatch_source}' | fields @timestamp, @message\n| stats count() as Requests by bin(1h) as SampleRate \n | sort SampleRate asc",
          "region" : "${var.aws_region}",
          "stacked" : false,
          "title" : "Amount of Requests over time",
          "view" : "bar"
        }
      }
    ]

  })
}
