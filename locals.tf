locals {
  metric_namespace = "AWS/ApiGateway"
  metric_name      = var.log_group_name != "" ? var.log_group_name : var.api_name
}
