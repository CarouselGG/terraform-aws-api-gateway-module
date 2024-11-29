variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "api_description" {
  description = "Description of the API Gateway"
  type        = string
  default     = null
}

variable "api_stage_name" {
  description = "Name of the API stage"
  type        = string
}

variable "api_stage_description" {
  description = "Description of the API stage"
  type        = string
  default     = null
}

variable "access_log_destination_arn" {
  description = "CloudWatch Log Group ARN for access logs"
  type        = string
}

variable "routes" {
  description = "Map of route keys to Lambda integration ARNs"
  type        = map(string)
}

variable "custom_domain_name" {
  description = "Custom domain name for API Gateway"
  type        = string
}

variable "hosted_zone_id" {
  description = "Hosted Zone ID for the custom domain"
  type        = string
}

variable "api_mapping_key" {
  description = "Mapping key for the API Gateway custom domain"
  type        = string
  default     = ""
}

// Cloudwatch Dashboard variables
variable "log_group_namespace" {
  description = "Namespace of the CloudWatch Log Group for API Gateway that prepends the log_group_name"
  type        = string
  default     = "/aws/http-api/"
}

variable "log_group_name" {
  description = "Name of the CloudWatch Log Group for API Gateway"
  type        = string
  default     = ""
}

variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "enable_dashboards" {
  description = "Flag to enable or disable the creation of CloudWatch Dashboards"
  type        = bool
  default     = false
}

variable "aws_region" {
  description = "AWS region for CloudWatch metrics"
  type        = string
}

variable "log_retention_in_days" {
  description = "Retention period for CloudWatch Log Group"
  type        = number
  default     = 14
}

variable "log_role_name" {
  description = "Name of the IAM Role for API Gateway CloudWatch logging"
  type        = string
}



