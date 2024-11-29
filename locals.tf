locals {
  log_group_name                = var.log_group_name == "" ? var.api_name : var.log_group_name
  log_group_name_with_namespace = "${var.log_group_namespace}${local.log_group_name}"
}
