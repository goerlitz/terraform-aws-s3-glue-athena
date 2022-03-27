resource "aws_athena_workgroup" "athena_workgroup" {
  name = "tft_athena_workgroup"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_results_bucket.id}/output/"
    }
  }
}

