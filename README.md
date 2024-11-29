# Terraform AWS API Gateway Module

This Terraform module creates and configures an AWS API Gateway (HTTP or REST), with optional support for custom domains, CloudWatch logging, and Lambda integrations.

## Created by Carousel

Author - [Loren M. Kerr](https://github.com/lmkerr 'Github Page for Loren M. Kerr')

## Features

- Configures an AWS API Gateway (HTTP or REST).
- Supports custom domain names with ACM certificates.
- Integrates with CloudWatch for logging.
- Configures API Gateway routes and Lambda integrations.

## Usage

```hcl
module "api_gateway" {
  source = "git::https://github.com/your-org/terraform-aws-api-gateway-module.git"

  api_name                = "example-api"
  api_description         = "Example API Gateway"
  api_stage_name          = "v1"
  api_stage_description   = "Production stage for Example API"
  custom_domain_name      = "api.example.com"
  hosted_zone_id          = "Z123456789EXAMPLE"
  log_group_name          = "/aws/http-api/example-api"
  log_retention_in_days   = 14
  log_role_name           = "example-api-logging-role"

  routes = {
    "GET /example"  = aws_lambda_function.example_lambda.invoke_arn
    "POST /example" = aws_lambda_function.example_post_lambda.invoke_arn
  }
}
