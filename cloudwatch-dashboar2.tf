resource "aws_cloudwatch_dashboard" "api_gateway_dashboard" {
  count = var.enable_dashboards ? 1 : 0

  dashboard_name = "${var.api_name}-dashboard"

  dashboard_body = jsonencode({
    "start" : "-PT3H",
    widgets = [
      {
        "height" : 1,
        "width" : 24,
        "y" : 0,
        "x" : 0,
        "type" : "text",
        "properties" : {
          "markdown" : "# ${var.api_name} API"
        }
      },

      {
        "height" : 6,
        "width" : 24,
        "y" : 1,
        "x" : 0,
        "type" : "log",
        "properties" : {

          "query" : "SOURCE '${local.cloudwatch_source}' | fields @timestamp, @message\n | stats sum(status like /^2\\d{2}$/) as OK, sum(status like /^3\\d{2}$/) as Redirects, sum(status like /^4\\d{2}$/) as BedRequests, sum(status like /^5\\d{2}$/) as Errors by bin(1h) as SampleRate\n | sort SampleRate asc\n",
          "region" : "${var.aws_region}",
          "title" : "Status Codes over Time",
          "view" : "bar"
        }
      }

      # Overall Traffic and Status Codes Widget (First Line)
    ]
  })
}
