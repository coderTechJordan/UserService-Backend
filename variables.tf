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