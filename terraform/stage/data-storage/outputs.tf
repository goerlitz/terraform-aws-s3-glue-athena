output "datasets_bucket_name" {
  description = "Name of the S3 bucket used to store datasets."
  value       = module.s3_data_bucket.id
}

output "datasets_bucket_arn" {
  description = "ARN of the S3 bucket used to store datasets."
  value       = module.s3_data_bucket.arn
}

output "lambda_bucket_name" {
  description = "Name of the S3 bucket used to store lambda functions."
  value = module.s3_lambda_bucket.id
}

output "lambda_bucket_arn" {
  description = "ARN of the S3 bucket used to store lambda functions."
  value = module.s3_lambda_bucket.arn
}

output "athena_results_bucket_name" {
  description = "Name of the S3 bucket used to store lambda functions."
  value = module.s3_athena_results_bucket.id
}

output "athena_results_bucket_arn" {
  description = "ARN of the S3 bucket used to store lambda functions."
  value = module.s3_athena_results_bucket.arn
}

output "s3_kms_key_name" {
  description = "Name of the kms key used to encrypt the buckets"
  value = aws_kms_key.s3_key.key_id
}

output "s3_kms_key_arn" {
  description = "ARN of the kms key used to encrypt the buckets"
  value = aws_kms_key.s3_key.arn
}
