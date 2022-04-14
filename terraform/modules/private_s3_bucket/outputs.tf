output "arn" {
  description = "ARN of the S3 bucket."
  value       = aws_s3_bucket.private_bucket.arn
}

output "id" {
  description = "Name/ID of the S3 bucket."
  value       = aws_s3_bucket.private_bucket.id
}
