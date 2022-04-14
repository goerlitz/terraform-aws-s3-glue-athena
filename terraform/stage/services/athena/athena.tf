resource "aws_athena_workgroup" "athena_workgroup" {
  name = "tft_athena_workgroup"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${data.terraform_remote_state.s3.outputs.athena_results_bucket_name}/output/"

      # encrypt query results in this workgroup
      encryption_configuration {
        encryption_option = "SSE_KMS"
        kms_key_arn       = "${data.terraform_remote_state.s3.outputs.s3_kms_key_arn}"  # KMS master key to use
      }
    }
  }
}
