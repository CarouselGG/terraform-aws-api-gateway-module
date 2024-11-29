# Terraform AWS API Gateway Module

This Terraform module creates and configures an AWS API Gateway (HTTP or REST), with optional support for custom domains, CloudWatch logging, and Lambda integrations.

## Created by Carousel

Author - [Loren M. Kerr](https://github.com/lmkerr 'Github Page for Loren M. Kerr')

## Features

- Configures an AWS API Gateway (HTTP or REST).
- Supports custom domain names with ACM certificates.
- Integrates with CloudWatch for logging.
- Configures API Gateway routes and Lambda integrations.

## Why use it?

- Easy to setup!
- API Gateway v2 can reduce API Gateway cost by nearly 70%!
- Why do it all yourself? It's free!

## Usage

```hcl
module "api_gateway" {
  source = "git::https://github.com/your-org/terraform-aws-api-gateway-module.git"

  api_name                = "example-api"
  api_description         = "Example API Gateway"
  api_stage_name          = "v1"
  api_stage_description   = "Production stage for Example API"
  aws_region              = "us-west-2"
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
```

> [!NOTE]
> Make sure you have a valid hostname and a domain / subdomain name that has been verified!

## Inputs

| Name                       | Description                                      | Type   | Default | Required |
|----------------------------|--------------------------------------------------|--------|---------|----------|
| access_log_destination_arn | CloudWatch Log Group ARN for access logs         | string | n/a     | yes      |
| api_description            | Description of the API Gateway                   | string | null    | no       |
| api_mapping_key            | Mapping key for the API Gateway custom domain    | string | ""      | no       |
| api_name                   | Name of the API Gateway                          | string | n/a     | yes      |
| api_stage_description      | Description of the API Gateway stage             | string | null    | no       |
| aws_region                 | Region for Cloudwatch Dashboard                  | string | n/a     | yes      |
| api_stage_name             | Name of the API Gateway stage                    | string | n/a     | yes      |
| custom_domain_name         | Custom domain name for the API Gateway           | string | n/a     | yes      |
| enable_dashboards          | Enable CloudWatch dashboards for API Gateway     | bool   | false   | no       |
| hosted_zone_id             | Hosted zone ID for the custom domain             | string | n/a     | yes      |
| log_group_name             | Name of the CloudWatch Log Group for API Gateway | string | n/a     | yes      |
| log_retention_in_days      | Retention period for the CloudWatch log group    | number | 14      | no       |
| log_role_name              | Name of the IAM role for CloudWatch logging      | string | n/a     | yes      |
| routes                     | Map of route keys to Lambda integration ARNs     | map    | n/a     | yes      |


## Outputs

| Name                   | Description                                       |
|------------------------|---------------------------------------------------|
| api_gateway_invoke_url | Invoke URL of the API Gateway                     |
| api_id                 | API Gateway ID                                    |
| certificate_arn        | ARN of the ACM Certificate for the custom domain  |
| custom_domain_name     | Custom domain name for the API Gateway            |
| execution_arn          | Execution ARN of the API Gateway                  |
| log_group_arn          | ARN of the CloudWatch Log Group                   |
| log_role_arn           | ARN of the IAM Role for CloudWatch                |
| route53_record_fqdn    | FQDN of the Route 53 record for the custom domain |
| stage_name             | Stage name of the API Gateway                     |


## License

This project is licensed under the MIT License - see the LICENSE file for details.