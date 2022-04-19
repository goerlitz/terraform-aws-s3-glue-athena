output "base_url" {
  description = "Base URL for API Gateway stage."
  value = aws_apigatewayv2_stage.lambda_api.invoke_url
}

output "lambda_api_inspect" {
  description = "Name of the Lambda function."
  value = module.lambda_api_inspect.function_name
}

output "lambda_api_download" {
  description = "Name of the Lambda function."
  value = module.lambda_api_download.function_name
}
