# CloudWatch Log Group for API Gateway logging
resource "aws_cloudwatch_log_group" "api_gateway_log_group" {
  name              = "/aws/http-api/${var.api_name}"
  retention_in_days = var.log_retention_in_days
}

# IAM Role for API Gateway to allow it to push logs to CloudWatch
resource "aws_iam_role" "api_gateway_cloudwatch_role" {
  name = var.log_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

# Policy to allow the IAM Role to write logs to CloudWatch
resource "aws_iam_role_policy" "api_gateway_cloudwatch_policy" {
  name = "${var.log_role_name}_policy"
  role = aws_iam_role.api_gateway_cloudwatch_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "cloudwatch:PutMetricData"
        ],
        Resource = "*"
      }
    ]
  })
}
