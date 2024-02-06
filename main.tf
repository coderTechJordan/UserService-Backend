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
  prefix = "jordan-terraform-bucket"
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

  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "private"
}

# Upload the JAR file directly to S3 without archiving it
resource "aws_s3_object" "lambda_get_users" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "UserServiceExecutable.jar"
  source = "${path.module}/target/UserService-0.0.1-SNAPSHOT.jar"
  etag   = filemd5("${path.module}/target/UserService-0.0.1-SNAPSHOT.jar")
}




resource "aws_lambda_function" "jordan-get-users" {
  function_name = "jordan-get-users"
  runtime       = "java17"
  handler       = "com.example.UserService.LambdaHandler::handleRequest"
  s3_bucket     = aws_s3_bucket.lambda_bucket.bucket
  s3_key        = aws_s3_object.lambda_get_users.key
  role          = aws_iam_role.lambda_exec.arn
  timeout       = 60
}

resource "aws_cloudwatch_log_group" "jordan-get-users" {
  name              = "/aws/lambda/${aws_lambda_function.jordan-get-users.function_name}"
  retention_in_days = 30
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
        Resource = [
          aws_lambda_function.jordan-get-users.arn,
          "arn:aws:logs:*:*:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_apigatewayv2_api" "lambda" {
  name          = "userService_lambda_gw"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["Authorization", "Content-Type"]
    max_age       = 3000
  }
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id      = aws_apigatewayv2_api.lambda.id
  name        = "serverless_lambda_stage"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn
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

resource "aws_cloudwatch_log_group" "api_gw" {
  name              = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"
  retention_in_days = 30
}

resource "aws_apigatewayv2_integration" "jordan-get-users" {
  api_id             = aws_apigatewayv2_api.lambda.id
  integration_uri    = aws_lambda_function.jordan-get-users.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "jordan-get-users" {
  api_id     = aws_apigatewayv2_api.lambda.id
  route_key  = "GET /users"
  target     = "integrations/${aws_apigatewayv2_integration.jordan-get-users.id}"
  depends_on = [aws_apigatewayv2_integration.jordan-get-users]
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromHTTPAPI"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.jordan-get-users.function_name
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
  description = "Policy for API Gateway to invoke Lambda function"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "lambda:InvokeFunction",
      Resource = aws_lambda_function.jordan-get-users.arn
    }]
  })
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

resource "aws_iam_policy" "dynamodb_policy" {
  name        = "dynamodb_access_policy"
  description = "IAM policy for accessing DynamoDB tables"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:DeleteItem"  # Include the missing action for DeleteItem
      ],
      Resource = [
        "arn:aws:dynamodb:us-east-2:866934333672:table/jordan-user-service",
        "arn:aws:dynamodb:us-east-2:866934333672:table/jordan-user-service/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy_attachment" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.dynamodb_policy.arn
}

# Add null_resource with local-exec provisioner to print current working directory and its contents
# resource "null_resource" "debugging" {
#  provisioner "local-exec" {
#    command = <<EOF
#      pwd
#      ls -al
#    EOF
#  }
# }
