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

variable "routes" {
  description = "Map of route Lambdas integration ARNs"
  type        = map(any)
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

variable "api_key" {
  description = "Optional API key to secure routes. If not provided, routes will not require an API key."
  type        = string
  default     = null
}

variable "log_group_name" {
  description = "Name of the CloudWatch Log Group for API Gateway"
  type        = string
  default     = null
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

variable "route_throttling_burst_limit" {
  description = "Burst limit for throttling"
  type        = number
  default     = 1000
}

variable "route_throttling_rate_limit" {
  description = "Rate limit for throttling"
  type        = number
  default     = 500
}

# Observability Variables

variable "enable_lambda_insights" {
  description = "Enable CloudWatch Lambda Insights widgets in the dashboard. Note: You must add the Lambda Insights layer to your Lambda functions separately."
  type        = bool
  default     = false
}

variable "enable_alarms" {
  description = "Enable CloudWatch alarms for API Gateway and Lambda monitoring"
  type        = bool
  default     = false
}

variable "create_sns_topic" {
  description = "Create an SNS topic for alarm notifications. If false and enable_alarms is true, alarm_sns_topic_arn must be provided."
  type        = bool
  default     = false
}

variable "sns_topic_name" {
  description = "Name for the SNS topic (only used if create_sns_topic is true). Defaults to {api_name}-alarms."
  type        = string
  default     = null
}

variable "alarm_sns_topic_arn" {
  description = "Existing SNS topic ARN for CloudWatch alarm notifications. Required if enable_alarms is true and create_sns_topic is false."
  type        = string
  default     = null
}

variable "alarm_thresholds" {
  description = "Thresholds for CloudWatch alarms"
  type = object({
    error_rate_percent    = number
    p99_latency_ms        = number
    lambda_error_percent  = number
    lambda_throttle_count = number
  })
  default = {
    error_rate_percent    = 5
    p99_latency_ms        = 3000
    lambda_error_percent  = 5
    lambda_throttle_count = 10
  }
}
