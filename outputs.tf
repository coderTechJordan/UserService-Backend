# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Output value definitions

output "lambda_bucket" {
  description = "Name of the S3 bucket used to store function code."
  value       = aws_s3_bucket.lambda_bucket.id
}

output "lambda_function_names" {
  description = "Names and ARNs of the Lambda functions."

  value = {
    create_user        = {
      name = aws_lambda_function.create_user.function_name
      arn  = data.aws_lambda_function.lambda_functions["create_user"].arn
    }
    list_users         = {
      name = aws_lambda_function.list_users.function_name
      arn  = data.aws_lambda_function.lambda_functions["list_users"].arn
    }
    get_user_by_id     = {
      name = aws_lambda_function.get_user_by_id.function_name
      arn  = data.aws_lambda_function.lambda_functions["get_user_by_id"].arn
    }
    update_user        = {
      name = aws_lambda_function.update_user.function_name
      arn  = data.aws_lambda_function.lambda_functions["update_user"].arn
    }
    delete_user        = {
      name = aws_lambda_function.delete_user.function_name
      arn  = data.aws_lambda_function.lambda_functions["delete_user"].arn
    }
    user_authentication = {
      name = aws_lambda_function.user_authentication.function_name
      arn  = data.aws_lambda_function.lambda_functions["user_authentication"].arn
    }
    user_logout        = {
      name = aws_lambda_function.user_logout.function_name
      arn  = data.aws_lambda_function.lambda_functions["user_logout"].arn
    }
    change_password    = {
      name = aws_lambda_function.change_password.function_name
      arn  = data.aws_lambda_function.lambda_functions["change_password"].arn
    }
    reset_password     = {
      name = aws_lambda_function.reset_password.function_name
      arn  = data.aws_lambda_function.lambda_functions["reset_password"].arn
    }
  }
}

output "base_urls" {
  description = "Base URLs for API Gateway stages."
  value       = {
    lambda = aws_apigatewayv2_stage.lambda.invoke_url
    # Add more stages if necessary
  }
}

output "api_gateway_id" {
  description = "The ID of the deployed API Gateway."
  value       = aws_apigatewayv2_api.lambda.id
}

output "lambda_execution_role_arn" {
  description = "The ARN of the IAM Role used by Lambda functions."
  value       = aws_iam_role.lambda_exec.arn
}

output "dynamodb_policy_arn" {
  value = aws_iam_policy.dynamodb_unified_access_policy.arn
}

output "cloudwatch_log_group_names" {
  description = "Names of the CloudWatch Log Groups for Lambda functions."
  value = {
    create_user_log_group        = aws_cloudwatch_log_group.create_user_log_group.name
    list_users_log_group         = aws_cloudwatch_log_group.list_users_log_group.name
    get_user_by_id_log_group     = aws_cloudwatch_log_group.get_user_by_id_log_group.name
    update_user_log_group        = aws_cloudwatch_log_group.update_user_log_group.name
    delete_user_log_group        = aws_cloudwatch_log_group.delete_user_log_group.name
    user_authentication_log_group = aws_cloudwatch_log_group.user_authentication_log_group.name
    user_logout_log_group        = aws_cloudwatch_log_group.user_logout_log_group.name
    change_password_log_group    = aws_cloudwatch_log_group.change_password_log_group.name
    reset_password_log_group     = aws_cloudwatch_log_group.reset_password_log_group.name
  }
}


output "lambda_bucket_arn" {
  description = "ARN of the S3 bucket used to store function code."
  value       = aws_s3_bucket.lambda_bucket.arn
}

output "s3_bucket_id" {
  description = "The name of the S3 bucket used for Lambda function code storage."
  value       = aws_s3_bucket.lambda_bucket.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket used for Lambda function code storage."
  value       = aws_s3_bucket.lambda_bucket.arn
}

output "s3_bucket_domain_name" {
  description = "The domain name of the S3 bucket."
  value       = aws_s3_bucket.lambda_bucket.bucket_domain_name
}

output "s3_bucket_regional_domain_name" {
  description = "The region-specific domain name of the S3 bucket."
  value       = aws_s3_bucket.lambda_bucket.bucket_regional_domain_name
}

output "s3_bucket_hosted_zone_id" {
  description = "The Route 53 Hosted Zone ID for the S3 bucket's region."
  value       = aws_s3_bucket.lambda_bucket.hosted_zone_id
}

# Note: Lifecycle configuration, policy, and website configurations would need to be extracted from your Terraform configurations if applied. Examples given assume these configurations are not explicitly defined in your `main.tf`.

# Example for S3 bucket lifecycle rules if you have them defined
# output "s3_bucket_lifecycle_rules" {
#   description = "The lifecycle rules configured for the S3 bucket, if any."
#   value       = jsonencode(aws_s3_bucket.lambda_bucket.lifecycle_rule)
# }

# Example for S3 bucket policy if you have one applied
# output "s3_bucket_policy" {
#   description = "The bucket policy as a JSON document, if the bucket is configured with a policy."
#   value       = aws_s3_bucket_policy.lambda_bucket.policy
# }

# Example for S3 bucket website endpoint if you have website configuration
# output "s3_bucket_website_endpoint" {
#   description = "The website endpoint URL, if the bucket is configured as a website."
#   value       = aws_s3_bucket.lambda_bucket.website_endpoint
# }
