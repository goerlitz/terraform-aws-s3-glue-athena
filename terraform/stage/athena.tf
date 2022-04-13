resource "aws_athena_workgroup" "athena_workgroup" {
  name = "tft_athena_workgroup"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_results_bucket.id}/output/"

      # encrypt query results in this workgroup
      encryption_configuration {
        encryption_option = "SSE_KMS"
        kms_key_arn       = aws_kms_key.s3_key.arn  # KMS master key to use
      }
    }
  }
}

