output "datasets_bucket_name" {
  description = "Name of the S3 bucket used to store datasets."
  value       = aws_s3_bucket.data_bucket.id
}

output "lambda_bucket_name" {
  description = "Name of the S3 bucket used to store lambda functions."
  value = aws_s3_bucket.lambda_bucket.id
}

output "data_api_func_name" {
  description = "Name of the Lambda function."

  value = aws_lambda_function.inspect_data.function_name
}

output "inspect_data_func_name" {
  description = "Name of the Lambda function."

  value = aws_lambda_function.inspect_data.function_name
}

output "lambda_policy" {
#  value = data.aws_iam_policy_document.example.json
  value = aws_iam_role_policy.lambda_exec_policy.policy
}

output "base_url" {
  description = "Base URL for API Gateway stage."

  value = aws_apigatewayv2_stage.lambda.invoke_url
}
