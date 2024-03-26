# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Input variable definitions

variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-2"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function."
  type        = string
  default     = "jordan-get-users"
}

variable "lambda_function_names" {
  description = "List of Lambda function names."
  type        = list(string)
  default     = []
}

variable "api_gateway_integrations" {
  description = "Map of API Gateway integrations."
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)."
  type        = string
  default     = "dev"
}

variable "account_id" {
  default = ""
}

variable "lambda_function_name_prefix" {
  default = ""
}


variable "lambda_runtime" {
  description = "Runtime environment for AWS Lambda functions."
  type        = string
  default     = "java17"
}

variable "lambda_timeout" {
  description = "The amount of time your Lambda Function has to run in seconds."
  type        = number
  default     = 60
}

variable "jar_file_key" {
  description = "S3 key for the JAR file."
  type        = string
  default     = "UserServiceExecutable.jar"
}

variable "cloudwatch_log_retention" {
  description = "Number of days to retain CloudWatch logs."
  type        = number
  default     = 30
}

variable "api_gateway_name" {
  description = "Name of the API Gateway."
  type        = string
  default     = "userService_lambda_gw"
}

variable "cors_allow_origins" {
  description = "CORS configuration for allowed origins."
  type        = list(string)
  default     = ["*"]
}

variable "cors_allow_methods" {
  description = "CORS configuration for allowed methods."
  type        = list(string)
  default     = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
}

variable "cors_allow_headers" {
  description = "CORS configuration for allowed headers."
  type        = list(string)
  default     = ["Authorization", "Content-Type"]
}

variable "cors_max_age" {
  description = "CORS configuration for max age."
  type        = number
  default     = 3000
}

variable "s3_bucket_prefix" {
  description = "Prefix for S3 bucket names to ensure uniqueness."
  type        = string
  default     = "jordan-terraform-bucket"
}

variable "jar_file_source_path" {
  description = "Path to the source JAR file to be uploaded to S3."
  type        = string
  default     = "target/UserService-0.0.1-SNAPSHOT.jar"
}

variable "api_gateway_stage_name" {
  description = "Stage name for the deployed API Gateway."
  type        = string
  default     = "dev"
}

variable "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table accessed by the Lambda functions."
  type        = string
  // Example default value, replace with your actual DynamoDB table ARN or make it required by omitting the default
  default     = "arn:aws:dynamodb:us-east-2:866934333672:table/jordan-user-service"
}
