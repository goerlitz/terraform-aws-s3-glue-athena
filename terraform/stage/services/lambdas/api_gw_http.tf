# https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-develop.html
# To create a functional API, you must have at least one route, integration, stage, and deployment.

# define HTTP API
resource "aws_apigatewayv2_api" "lambda" {
  name          = "serverless_lambda_gw"
  protocol_type = "HTTP"
}

# define lambda integration (AWS_PROXY)
# https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-develop-integrations-lambda.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_integration
resource "aws_apigatewayv2_integration" "inspect_data" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.inspect_data.invoke_arn
  integration_type   = "AWS_PROXY"
  # integration_method = "POST"
}

resource "aws_apigatewayv2_integration" "download" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.download.invoke_arn
  integration_type   = "AWS_PROXY"
  # integration_method = "POST"
}

# define API routes
# https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-develop-routes.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_route
resource "aws_apigatewayv2_route" "inspect_data" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "POST /inspect"
  target    = "integrations/${aws_apigatewayv2_integration.inspect_data.id}"
}

resource "aws_apigatewayv2_route" "download" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "POST /download"
  target    = "integrations/${aws_apigatewayv2_integration.download.id}"
}

# define deployment stage
# https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-stages.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_stage
resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id

  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    }
    )
  }
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"

  kms_key_id = data.terraform_remote_state.s3.outputs.s3_kms_key_arn  # use specific key - otherwise default aws log encryption
  retention_in_days = 30
}

resource "aws_lambda_permission" "api_gw_inspect" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.inspect_data.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gw_download" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.download.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}
