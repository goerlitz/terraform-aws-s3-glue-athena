# https://aws.amazon.com/premiumsupport/knowledge-center/access-denied-athena/
# https://aws.amazon.com/premiumsupport/knowledge-center/athena-output-bucket-error/

resource "null_resource" "lambda_zip_prep" {

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = join(" && ", [
      "rm -r ${path.module}/../dist/data-api/node_modules",
      "cp -r ${path.module}/../node_modules ${path.module}/../dist/data-api/node_modules"
      # "zip -rq ${path.module}/../dist-aws/lambda.zip ${path.module}/../node_modules",
      # "zip -jq ${path.module}/../dist-aws/lambda.zip ${path.module}/../dist/data-api/*.js",
    ])
  }
}

data "archive_file" "lambda_data_api" {
  type = "zip"

  source_dir  = "${path.module}/../dist/data-api"
  output_path = "${path.module}/../dist-aws/data-api.zip"

  depends_on = [null_resource.lambda_zip_prep]
}

resource "aws_s3_object" "lambda_dist" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "data-api.zip"
  source = data.archive_file.lambda_data_api.output_path
  etag = data.archive_file.lambda_data_api.output_md5
}

resource "aws_lambda_function" "inspect_data" {
  function_name = "InspectData"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_dist.key

  runtime = "nodejs14.x"
  handler = "analysis.handler"
  timeout = 30
  reserved_concurrent_executions = -1

  source_code_hash = data.archive_file.lambda_data_api.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "inspect_data" {
  name = "/aws/lambda/${aws_lambda_function.inspect_data.function_name}"

  kms_key_id = aws_kms_key.s3_key.arn  # use specific key - otherwise default aws log encryption
  retention_in_days = 30
}

resource "aws_lambda_function" "download" {
  function_name = "Download"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_dist.key

  runtime = "nodejs14.x"
  handler = "download.handler"
  timeout = 30
  reserved_concurrent_executions = -1

  source_code_hash = data.archive_file.lambda_data_api.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "download" {
  name = "/aws/lambda/${aws_lambda_function.download.function_name}"

  kms_key_id = aws_kms_key.s3_key.arn  # use specific key - otherwise default aws log encryption
  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "LambdaExec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
  ]
}

resource "aws_iam_role_policy" "lambda_exec_policy" {
  name = "lambda_exec_policy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [ "s3:ListBucket" ]
        Effect   = "Allow"
        Resource = [ aws_s3_bucket.data_bucket.arn ]
      },
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
        ]
        Effect   = "Allow"
        Resource = [ "${aws_s3_bucket.data_bucket.arn}/*" ]
      },
      {
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
        ]
        Effect   = "Allow"
        Resource = [
          aws_s3_bucket.athena_results_bucket.arn
        ]
      },
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts",
        ]
        Effect   = "Allow"
        Resource = [
          "${aws_s3_bucket.athena_results_bucket.arn}/output/*"
        ]
      },
      {
        Action = [
          "glue:GetTable",
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:catalog",
          aws_glue_catalog_database.datasets_db.arn,
          "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:table/${aws_glue_catalog_database.datasets_db.name}/*",
        ]
      },
      {
        Action = [
          "athena:GetQueryExecution",
          "athena:GetQueryResults",
          "athena:StartQueryExecution",
          "athena:StopQueryExecution",
        ]
        Effect   = "Allow"
        Resource = [
          aws_athena_workgroup.athena_workgroup.arn
        ]
      },
    ]
  })
}
