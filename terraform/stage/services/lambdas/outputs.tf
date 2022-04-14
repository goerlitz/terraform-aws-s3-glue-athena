output "data_api_func_name" {
  description = "Name of the Lambda function."

  value = aws_lambda_function.inspect_data.function_name
}

output "inspect_data_func_name" {
  description = "Name of the Lambda function."

  value = aws_lambda_function.inspect_data.function_name
}

output "lambda_download" {
  description = "Name of the Lambda function."

  value = aws_lambda_function.download.function_name
}

output "base_url" {
  description = "Base URL for API Gateway stage."

  value = aws_apigatewayv2_stage.lambda.invoke_url
}
