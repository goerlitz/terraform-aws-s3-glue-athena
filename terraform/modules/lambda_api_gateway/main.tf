# Definition of an api_gateway for a lambda function

resource "aws_lambda_function" "lambda" {
  function_name    = var.function_name

  s3_bucket        = var.source_code_bucket
  s3_key           = var.source_code_key
  source_code_hash = var.source_code_hash

  runtime = "nodejs14.x"
  handler = var.function_handler
  timeout = var.function_timeout
  reserved_concurrent_executions = -1

  role = var.lambda_iam_role_arn
}

resource "aws_cloudwatch_log_group" "lambda" {
  name = "/aws/lambda/${aws_lambda_function.lambda.function_name}"

  kms_key_id = var.s3_kms_key_arn  # use specific key - otherwise default aws log encryption
  retention_in_days = 30
}

# define lambda HTTP API integration (AWS_PROXY)
# https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-develop-integrations-lambda.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_integration

resource "aws_apigatewayv2_integration" "lambda" {
  api_id = var.lambda_api_id

  integration_uri    = aws_lambda_function.lambda.invoke_arn
  integration_type   = "AWS_PROXY"
  # integration_method = "POST"
}

# define API route
# https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-develop-routes.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_route

resource "aws_apigatewayv2_route" "lambda" {
  api_id = var.lambda_api_id

  route_key = var.function_url
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_lambda_permission" "api_gw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${var.lambda_api_exec_arn}/*/*"
}
