# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      hashicorp-learn = "lambda-api-gateway"
    }
  }
}

resource "random_pet" "lambda_bucket" {
  prefix = var.s3_bucket_prefix
  length = 4
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = random_pet.lambda_bucket.id
}

resource "aws_s3_bucket_ownership_controls" "lambda_bucket" {
  bucket = aws_s3_bucket.lambda_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "lambda_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.lambda_bucket]
  bucket     = aws_s3_bucket.lambda_bucket.id
  acl        = "private"
}

# Upload the JAR file directly to S3 without archiving it
resource "aws_s3_object" "lambda_user_service_bucket" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = var.jar_file_key
  source = var.jar_file_source_path
  etag   = filemd5(var.jar_file_source_path)
}

resource "aws_lambda_function" "create_user" {
  function_name = "create-user-lambda-${var.environment}-${var.aws_region}"
  runtime       = var.lambda_runtime
  handler       = "com.example.CreateUser.LambdaHandler::handleRequest"
  s3_bucket     = aws_s3_bucket.lambda_bucket.bucket
  s3_key        = aws_s3_object.lambda_user_service_bucket.key
  role          = aws_iam_role.lambda_exec.arn
  timeout       = var.lambda_timeout
}

resource "aws_lambda_function" "list_users" {
  function_name = "list-users-lambda-${var.environment}-${var.aws_region}"
  runtime       = var.lambda_runtime
  handler       = "com.example.ListUsers.LambdaHandler::handleRequest"
  s3_bucket     = aws_s3_bucket.lambda_bucket.bucket
  s3_key        = aws_s3_object.lambda_user_service_bucket.key
  role          = aws_iam_role.lambda_exec.arn
  timeout       = var.lambda_timeout
}

# Declare the missing lambda function resources
resource "aws_lambda_function" "get_user_by_id" {
  function_name = "get-user-by-id-lambda-${var.environment}-${var.aws_region}"
  runtime       = var.lambda_runtime
  handler       = "com.example.GetUserById.LambdaHandler::handleRequest"
  s3_bucket     = aws_s3_bucket.lambda_bucket.bucket
  s3_key        = aws_s3_object.lambda_user_service_bucket.key
  role          = aws_iam_role.lambda_exec.arn
  timeout       = var.lambda_timeout
}

resource "aws_lambda_function" "update_user" {
  function_name = "update-user-lambda-${var.environment}-${var.aws_region}"
  runtime       = var.lambda_runtime
  handler       = "com.example.UpdateUser.LambdaHandler::handleRequest"
  s3_bucket     = aws_s3_bucket.lambda_bucket.bucket
  s3_key        = aws_s3_object.lambda_user_service_bucket.key
  role          = aws_iam_role.lambda_exec.arn
  timeout       = var.lambda_timeout
}

resource "aws_lambda_function" "delete_user" {
  function_name = "delete-user-lambda-${var.environment}-${var.aws_region}"
  runtime       = var.lambda_runtime
  handler       = "com.example.DeleteUser.LambdaHandler::handleRequest"
  s3_bucket     = aws_s3_bucket.lambda_bucket.bucket
  s3_key        = aws_s3_object.lambda_user_service_bucket.key
  role          = aws_iam_role.lambda_exec.arn
  timeout       = var.lambda_timeout
}


resource "aws_lambda_function" "user_authentication" {
  function_name = "user-auth-${var.environment}-${var.aws_region}"
  runtime       = var.lambda_runtime
  handler       = "com.example.UserAuthentication.LambdaHandler::handleRequest"
  s3_bucket     = aws_s3_bucket.lambda_bucket.bucket
  s3_key        = aws_s3_object.lambda_user_service_bucket.key
  role          = aws_iam_role.lambda_exec.arn
  timeout       = var.lambda_timeout
}

resource "aws_lambda_function" "user_logout" {
  function_name = "user-logout-lambda"
  runtime       = var.lambda_runtime
  handler       = "com.example.UserLogout.LambdaHandler::handleRequest"
  s3_bucket     = aws_s3_bucket.lambda_bucket.bucket
  s3_key        = aws_s3_object.lambda_user_service_bucket.key
  role          = aws_iam_role.lambda_exec.arn
  timeout       = var.lambda_timeout
}

resource "aws_lambda_function" "change_password" {
  function_name = "change-password-lambda"
  runtime       = var.lambda_runtime
  handler       = "com.example.ChangePassword.LambdaHandler::handleRequest"
  s3_bucket     = aws_s3_bucket.lambda_bucket.bucket
  s3_key        = aws_s3_object.lambda_user_service_bucket.key
  role          = aws_iam_role.lambda_exec.arn
  timeout       = var.lambda_timeout
}

resource "aws_lambda_function" "reset_password" {
  function_name = "reset-password-lambda"
  runtime       = var.lambda_runtime
  handler       = "com.example.ResetPassword.LambdaHandler::handleRequest"
  s3_bucket     = aws_s3_bucket.lambda_bucket.bucket
  s3_key        = aws_s3_object.lambda_user_service_bucket.key
  role          = aws_iam_role.lambda_exec.arn
  timeout       = var.lambda_timeout
}


# Create CloudWatch log groups for Lambda functions
resource "aws_cloudwatch_log_group" "create_user_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.create_user.function_name}"
  retention_in_days = var.cloudwatch_log_retention
}

resource "aws_cloudwatch_log_group" "list_users_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.list_users.function_name}"
  retention_in_days = var.cloudwatch_log_retention
}

resource "aws_cloudwatch_log_group" "get_user_by_id_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.get_user_by_id.function_name}"
  retention_in_days = var.cloudwatch_log_retention
}

resource "aws_cloudwatch_log_group" "update_user_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.update_user.function_name}"
  retention_in_days = var.cloudwatch_log_retention
}

resource "aws_cloudwatch_log_group" "delete_user_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.delete_user.function_name}"
  retention_in_days = var.cloudwatch_log_retention
}

resource "aws_cloudwatch_log_group" "user_authentication_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.user_authentication.function_name}"
  retention_in_days = var.cloudwatch_log_retention
}

resource "aws_cloudwatch_log_group" "user_logout_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.user_logout.function_name}"
  retention_in_days = var.cloudwatch_log_retention
}

resource "aws_cloudwatch_log_group" "change_password_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.change_password.function_name}"
  retention_in_days = var.cloudwatch_log_retention
}

resource "aws_cloudwatch_log_group" "reset_password_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.reset_password.function_name}"
  retention_in_days = var.cloudwatch_log_retention
}

# Create CloudWatch log group for API Gateway
resource "aws_cloudwatch_log_group" "api_gw_log_group" {
  name              = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"
  retention_in_days = var.cloudwatch_log_retention
}

# Attach CloudWatch log group policy to IAM role
resource "aws_iam_policy" "cloudwatch_log_policy" {
  name        = "cloudwatch_log_policy"
  description = "IAM policy for logging to CloudWatch"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      Resource = [
        aws_cloudwatch_log_group.create_user_log_group.arn,
        aws_cloudwatch_log_group.list_users_log_group.arn,
        aws_cloudwatch_log_group.get_user_by_id_log_group.arn,
        aws_cloudwatch_log_group.update_user_log_group.arn,
        aws_cloudwatch_log_group.delete_user_log_group.arn,
        aws_cloudwatch_log_group.user_authentication_log_group.arn,
        aws_cloudwatch_log_group.user_logout_log_group.arn,
        aws_cloudwatch_log_group.change_password_log_group.arn,
        aws_cloudwatch_log_group.reset_password_log_group.arn,
        aws_cloudwatch_log_group.api_gw_log_group.arn
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_log_policy_attachment" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.cloudwatch_log_policy.arn
}


resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Sid       = "",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

#resource "aws_iam_role" "serverless_lambda" {
#  name = "serverless_lambda"
#
#  assume_role_policy = jsonencode({
#    Version = "2012-10-17",
#    Statement = [
#      {
#        Action = "sts:AssumeRole",
#        Effect = "Allow",
#        Principal = {
#          Service = "lambda.amazonaws.com"
#        },
#        Sid = ""
#      },
#    ],
#  })
#}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-exec-policy"
  description = "Policy for allowing Lambda execution"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "lambda:InvokeFunction",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
  name       = "lambda-exec-policy-attachment"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_apigatewayv2_api" "lambda" {
  name          = var.api_gateway_name
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = var.cors_allow_origins
    allow_methods = var.cors_allow_methods
    allow_headers = var.cors_allow_headers
    max_age       = var.cors_max_age
  }
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id      = aws_apigatewayv2_api.lambda.id
  name        = var.api_gateway_stage_name
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw_log_group.arn
    format          = jsonencode({
      requestId               = "$context.requestId",
      sourceIp                = "$context.identity.sourceIp",
      requestTime             = "$context.requestTime",
      protocol                = "$context.protocol",
      httpMethod              = "$context.httpMethod",
      resourcePath            = "$context.resourcePath",
      routeKey                = "$context.routeKey",
      status                  = "$context.status",
      responseLength          = "$context.responseLength",
      integrationErrorMessage = "$context.integrationErrorMessage",
    })
  }
}

# Data source to fetch Lambda function ARNs
data "aws_lambda_function" "lambda_functions" {
  for_each = {
    create_user        = aws_lambda_function.create_user.function_name,
    list_users         = aws_lambda_function.list_users.function_name,
    get_user_by_id     = aws_lambda_function.get_user_by_id.function_name,
    update_user        = aws_lambda_function.update_user.function_name,
    delete_user        = aws_lambda_function.delete_user.function_name,
    user_authentication = aws_lambda_function.user_authentication.function_name,
    user_logout        = aws_lambda_function.user_logout.function_name,
    change_password    = aws_lambda_function.change_password.function_name,
    reset_password     = aws_lambda_function.reset_password.function_name,
  }

  function_name = each.value
}

# Create API Gateway integrations for each Lambda function
resource "aws_apigatewayv2_integration" "lambda_integrations" {
  for_each = data.aws_lambda_function.lambda_functions

  api_id             = aws_apigatewayv2_api.lambda.id
  integration_uri    = each.value.arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

# Create API Gateway routes for each Lambda function
resource "aws_apigatewayv2_route" "lambda_routes" {
  for_each = {
    for key, integration in aws_apigatewayv2_integration.lambda_integrations : key => integration
  }

  api_id    = aws_apigatewayv2_api.lambda.id
  route_key = each.key != "user_authentication" && each.key != "user_logout" ? "POST /${replace(each.key, "_", "/")}" : "ANY /${replace(each.key, "_", "/")}"
  target    = "integrations/${each.value.id}"
}

data "aws_lambda_function" "functions" {
  count = length(var.lambda_function_names)

  function_name = var.lambda_function_names[count.index]
}

resource "aws_apigatewayv2_integration" "create_user" {
  api_id             = aws_apigatewayv2_api.lambda.id
  integration_uri    = aws_lambda_function.create_user.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_integration" "list_users" {
  api_id             = aws_apigatewayv2_api.lambda.id
  integration_uri    = aws_lambda_function.list_users.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_integration" "get_user_by_id" {
  api_id             = aws_apigatewayv2_api.lambda.id
  integration_uri    = aws_lambda_function.get_user_by_id.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_integration" "update_user" {
  api_id             = aws_apigatewayv2_api.lambda.id
  integration_uri    = aws_lambda_function.update_user.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_integration" "delete_user" {
  api_id             = aws_apigatewayv2_api.lambda.id
  integration_uri    = aws_lambda_function.delete_user.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_integration" "user_authentication" {
  api_id             = aws_apigatewayv2_api.lambda.id
  integration_uri    = aws_lambda_function.user_authentication.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_integration" "user_logout" {
  api_id             = aws_apigatewayv2_api.lambda.id
  integration_uri    = aws_lambda_function.user_logout.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_integration" "change_password" {
  api_id             = aws_apigatewayv2_api.lambda.id
  integration_uri    = aws_lambda_function.change_password.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_integration" "reset_password" {
  api_id             = aws_apigatewayv2_api.lambda.id
  integration_uri    = aws_lambda_function.reset_password.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}


resource "aws_apigatewayv2_route" "create_user" {
  api_id    = aws_apigatewayv2_api.lambda.id
  route_key = "POST /users"
  target    = "integrations/${aws_apigatewayv2_integration.create_user.id}"
  depends_on = [aws_apigatewayv2_integration.create_user]
}

resource "aws_apigatewayv2_route" "list_users" {
  api_id    = aws_apigatewayv2_api.lambda.id
  route_key = "GET /users"
  target    = "integrations/${aws_apigatewayv2_integration.list_users.id}"
  depends_on = [aws_apigatewayv2_integration.list_users]
}

resource "aws_apigatewayv2_route" "get_user_by_id" {
  api_id    = aws_apigatewayv2_api.lambda.id
  route_key = "GET /users/{userId}"
  target    = "integrations/${aws_apigatewayv2_integration.get_user_by_id.id}"
  depends_on = [aws_apigatewayv2_integration.get_user_by_id]
}

resource "aws_apigatewayv2_route" "update_user" {
  api_id    = aws_apigatewayv2_api.lambda.id
  route_key = "PUT /users/{userId}"
  target    = "integrations/${aws_apigatewayv2_integration.update_user.id}"
  depends_on = [aws_apigatewayv2_integration.update_user]
}

resource "aws_apigatewayv2_route" "delete_user" {
  api_id    = aws_apigatewayv2_api.lambda.id
  route_key = "DELETE /users/{userId}"
  target    = "integrations/${aws_apigatewayv2_integration.delete_user.id}"
  depends_on = [aws_apigatewayv2_integration.delete_user]
}

resource "aws_apigatewayv2_route" "user_authentication" {
  api_id    = aws_apigatewayv2_api.lambda.id
  route_key = "POST /auth/login"
  target    = "integrations/${aws_apigatewayv2_integration.user_authentication.id}"
  depends_on = [aws_apigatewayv2_integration.user_authentication]
}

resource "aws_apigatewayv2_route" "user_logout" {
  api_id    = aws_apigatewayv2_api.lambda.id
  route_key = "POST /auth/logout"
  target    = "integrations/${aws_apigatewayv2_integration.user_logout.id}"
  depends_on = [aws_apigatewayv2_integration.user_logout]
}

resource "aws_apigatewayv2_route" "change_password" {
  api_id    = aws_apigatewayv2_api.lambda.id
  route_key = "PUT /users/{userId}/changepassword"
  target    = "integrations/${aws_apigatewayv2_integration.change_password.id}"
  depends_on = [aws_apigatewayv2_integration.change_password]
}

resource "aws_apigatewayv2_route" "reset_password" {
  api_id    = aws_apigatewayv2_api.lambda.id
  route_key = "POST /users/resetpassword"
  target    = "integrations/${aws_apigatewayv2_integration.reset_password.id}"
  depends_on = [aws_apigatewayv2_integration.reset_password]
}

resource "aws_lambda_permission" "create_user_api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}

resource "aws_lambda_permission" "change_password_api_gw" {
  statement_id  = "AllowExecutionFromHTTPAPIChangePassword"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.change_password.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}

resource "aws_lambda_permission" "update_user_api_gw" {
  statement_id  = "AllowExecutionFromHTTPAPIUpdateUser"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}

resource "aws_lambda_permission" "reset_password_api_gw" {
  statement_id  = "AllowExecutionFromHTTPAPIResetPassword"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.reset_password.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}

resource "aws_lambda_permission" "list_users_api_gw" {
  statement_id  = "AllowExecutionFromHTTPAPIListUsers"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_users.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}

resource "aws_lambda_permission" "user_logout_api_gw" {
  statement_id  = "AllowExecutionFromHTTPAPIUserLogout"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.user_logout.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}

resource "aws_lambda_permission" "get_user_by_id_api_gw" {
  statement_id  = "AllowExecutionFromHTTPAPIGetUserById"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_user_by_id.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}

resource "aws_lambda_permission" "delete_user_api_gw" {
  statement_id  = "AllowExecutionFromHTTPAPIDeleteUser"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}

resource "aws_lambda_permission" "user_authentication_api_gw" {
  statement_id  = "AllowExecutionFromHTTPAPIUserAuthentication"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.user_authentication.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}

resource "aws_iam_role" "api_gateway_role" {
  name = "api_gateway_lambda_role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "apigateway.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "api_gateway_policy" {
  name        = "api_gateway_lambda_policy"
  description = "Policy for API Gateway to invoke Lambda functions"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Action    = "lambda:InvokeFunction",
      Resource  = [
        aws_lambda_function.create_user.arn,
        aws_lambda_function.list_users.arn,
        aws_lambda_function.get_user_by_id.arn,
        aws_lambda_function.update_user.arn,
        aws_lambda_function.delete_user.arn,
        aws_lambda_function.user_authentication.arn,
        aws_lambda_function.user_logout.arn,
        aws_lambda_function.change_password.arn,
        aws_lambda_function.reset_password.arn,
      ]
    }]
  })
}

resource "aws_iam_policy" "api_gateway_invoke_lambda_policy" {
  name        = "api_gateway_invoke_lambda_policy"
  description = "IAM policy for API Gateway to invoke Lambda functions"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Action    = [
        "lambda:InvokeFunction",
        "lambda:InvokeAsync"
      ],
      Resource  = "*"
    }]
  })
}


resource "aws_iam_policy_attachment" "api_gateway_invoke_lambda_attachment" {
  name       = "api_gateway_invoke_lambda_attachment"
  roles      = [aws_iam_role.api_gateway_role.name]
  policy_arn = aws_iam_policy.api_gateway_invoke_lambda_policy.arn
}

resource "aws_iam_policy_attachment" "api_gateway_policy_attachment" {
  name       = "api_gateway_lambda_policy_attachment"
  roles      = [aws_iam_role.api_gateway_role.name]
  policy_arn = aws_iam_policy.api_gateway_policy.arn
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      Resource = "arn:aws:logs:*:*:*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

# DynamoDB IAM Policy Attachment
resource "aws_iam_policy" "dynamodb_unified_access_policy" {
  name        = "DynamoDBUnifiedAccessPolicy"
  description = "Unified policy that allows Lambda functions to access DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ],
        Resource = var.dynamodb_table_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dynamodb_unified_access_attachment_lambda_exec" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.dynamodb_unified_access_policy.arn
}

#resource "aws_iam_role_policy_attachment" "dynamodb_unified_access_attachment_serverless_lambda" {
#  role       = aws_iam_role.serverless_lambda.name  # Ensure this role is defined as shown above
#  policy_arn = aws_iam_policy.dynamodb_unified_access_policy.arn
#}



resource "aws_iam_role_policy_attachment" "api_gateway_policy_attachment" {
  role       = aws_iam_role.api_gateway_role.name
  policy_arn = aws_iam_policy.api_gateway_policy.arn
}