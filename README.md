# Terraform AWS API Gateway Module

This Terraform module creates and configures an AWS API Gateway v2 (HTTP API), with support for custom domains, CloudWatch logging, dashboards, alarms, and Lambda integrations.

## Created by Carousel

Author - [Loren M. Kerr](https://github.com/lmkerr 'Github Page for Loren M. Kerr')

## Features

- Configures an AWS API Gateway v2 (HTTP API)
- Supports custom domain names with ACM certificates
- Integrates with CloudWatch for logging
- Configures API Gateway routes and Lambda integrations
- Optional CloudWatch dashboard with API Gateway, per-route, and Lambda metrics
- Optional CloudWatch alarms for error rates, latency, and throttling
- Optional Lambda Insights support for enhanced monitoring

## Why use it?

- Easy to setup!
- API Gateway v2 can reduce API Gateway cost by nearly 70%!
- Built-in observability with comprehensive dashboards and alarms
- Why do it all yourself? It's free!

## Usage

```hcl
module "api_gateway" {
  source  = "CarouselGG/api-gateway-module/aws"
  version = "0.3.0"

  # API Configuration
  api_name              = "example-api"
  api_description       = "Example API Gateway"
  api_stage_name        = "v1"
  api_stage_description = "Production stage for Example API"

  # AWS Configuration
  aws_region = "us-west-2"

  # Custom Domain Configuration
  custom_domain_name = "api.example.com"
  hosted_zone_id     = "Z123456789EXAMPLE"

  # Logging Configuration
  log_group_name        = "example-api"
  log_retention_in_days = 14
  log_role_name         = "example-api-logging-role"

  # Routes & Integrations
  routes = {
    "GET /example"                   = aws_lambda_function.example_lambda
    "POST /example"                  = aws_lambda_function.example_post_lambda
    "PUT /example/thing/{myThingId}" = aws_lambda_function.update_thing_lambda
  }

  # Observability (optional)
  enable_dashboards = true
  enable_alarms     = true
  alarm_sns_topic_arn = aws_sns_topic.alerts.arn
}
```

> [!NOTE]
> Make sure you have a valid hostname and a domain / subdomain name that has been verified!

## Monitoring & Observability

This module provides comprehensive monitoring capabilities for your API Gateway and Lambda functions.

### CloudWatch Dashboard

Enable with `enable_dashboards = true`. Creates a single combined dashboard with:

**API Gateway Metrics:**
- Request volume (total requests, 2xx success)
- Error rates (3xx, 4xx, 5xx, other)
- Latency percentiles (p50, p90, p99)
- Success rate gauge

**Per-Route Metrics:**
- Requests by route
- Latency by route (p99)

**Lambda Metrics:**
- Invocations per function
- Errors per function
- Duration percentiles (p50, p99)
- Throttles and concurrent executions

### CloudWatch Alarms

Enable with `enable_alarms = true`. You have two options for the SNS topic:

#### Option 1: Let the module create an SNS topic

```hcl
enable_alarms    = true
create_sns_topic = true
sns_topic_name   = "my-api-alarms"  # optional, defaults to {api_name}-alarms
```

#### Option 2: Use an existing SNS topic

```hcl
enable_alarms       = true
alarm_sns_topic_arn = aws_sns_topic.my_existing_topic.arn
```

Creates alarms for:

**API Gateway:**
- 5xx error rate exceeds threshold (default: 5%)
- P99 latency exceeds threshold (default: 3000ms)
- 4xx error rate elevated (default: 20%)

**Lambda (per function):**
- Error rate exceeds threshold (default: 5%)
- Throttles exceed threshold (default: 10)
- Duration approaching timeout
- High concurrent executions

### Lambda Insights

For enhanced Lambda metrics (memory utilization, cold starts), enable Lambda Insights:

1. Set `enable_lambda_insights = true` in this module
2. Add the Lambda Insights layer to your Lambda functions:

```hcl
resource "aws_lambda_function" "example" {
  # ... other configuration ...

  layers = [
    module.api_gateway.lambda_insights_layer_arn
  ]

  # Required IAM policy for Lambda Insights
  # Attach the managed policy: arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| api_name | Name of the API Gateway | string | n/a | yes |
| api_description | Description of the API Gateway | string | null | no |
| api_stage_name | Name of the API Gateway stage | string | n/a | yes |
| api_stage_description | Description of the API Gateway stage | string | null | no |
| aws_region | AWS region for CloudWatch metrics and dashboard | string | n/a | yes |
| routes | Map of route keys to Lambda integration ARNs | map(any) | n/a | yes |
| custom_domain_name | Custom domain name for the API Gateway | string | n/a | yes |
| hosted_zone_id | Hosted zone ID for the custom domain | string | n/a | yes |
| api_mapping_key | Mapping key for the API Gateway custom domain | string | "" | no |
| api_key | Protect each route with a single API key | string | null | no |
| log_group_name | Name of the CloudWatch Log Group | string | null | no |
| log_retention_in_days | Retention period for the CloudWatch log group | number | 14 | no |
| log_role_name | Name of the IAM role for CloudWatch logging | string | n/a | yes |
| route_throttling_burst_limit | Burst limit for route throttling | number | 1000 | no |
| route_throttling_rate_limit | Rate limit for route throttling | number | 500 | no |
| enable_dashboards | Enable CloudWatch dashboards and metric filters | bool | false | no |
| enable_lambda_insights | Enable Lambda Insights widgets in dashboard | bool | false | no |
| enable_alarms | Enable CloudWatch alarms for monitoring | bool | false | no |
| create_sns_topic | Create an SNS topic for alarm notifications | bool | false | no |
| sns_topic_name | Name for created SNS topic (defaults to {api_name}-alarms) | string | null | no |
| alarm_sns_topic_arn | Existing SNS topic ARN (required if enable_alarms=true and create_sns_topic=false) | string | null | no |
| alarm_thresholds | Thresholds for CloudWatch alarms | object | see below | no |

### Alarm Thresholds Object

```hcl
alarm_thresholds = {
  error_rate_percent    = 5     # API Gateway 5xx error rate threshold (%)
  p99_latency_ms        = 3000  # API Gateway P99 latency threshold (ms)
  lambda_error_percent  = 5     # Lambda error rate threshold (%)
  lambda_throttle_count = 10    # Lambda throttle count threshold
}
```

## Outputs

| Name | Description |
|------|-------------|
| api_gateway_invoke_url | Invoke URL of the API Gateway |
| api_id | API Gateway ID |
| stage_name | Stage name of the API Gateway |
| execution_arn | Execution ARN of the API Gateway |
| custom_domain_name | Custom domain name for the API Gateway |
| route53_record_fqdn | FQDN of the Route 53 record for the custom domain |
| certificate_arn | ARN of the ACM Certificate for the custom domain |
| log_group_arn | ARN of the CloudWatch Log Group |
| log_role_arn | ARN of the IAM Role for CloudWatch logging |
| dashboard_name | Name of the CloudWatch dashboard (null if disabled) |
| dashboard_url | URL to the CloudWatch dashboard in AWS Console (null if disabled) |
| lambda_insights_layer_arn | ARN of the Lambda Insights layer for this region |
| sns_topic_arn | ARN of the SNS topic for alarms (null if not created by module) |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## License

This project is licensed under the MIT License - see the LICENSE file for details.
