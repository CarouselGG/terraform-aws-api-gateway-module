locals {
  log_group_name_with_namespace = var.log_group_name ? "AWS/ApiGateway/${var.log_group_name}" : "AWS/ApiGateway/${var.api_name}"
}
