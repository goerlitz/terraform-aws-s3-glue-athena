# https://aws.amazon.com/premiumsupport/knowledge-center/access-denied-athena/
# https://aws.amazon.com/premiumsupport/knowledge-center/athena-output-bucket-error/

data "archive_file" "lambda_hello_world" {
  type = "zip"

  source_dir  = "${path.module}/../src/data-api"
  output_path = "${path.module}/hello-world.zip"
}

resource "aws_s3_object" "lambda_hello_world" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "hello-world.zip"
  source = data.archive_file.lambda_hello_world.output_path

  etag = filemd5(data.archive_file.lambda_hello_world.output_path)
}

resource "aws_lambda_function" "hello_world" {
  function_name = "HelloWorld"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_hello_world.key

  runtime = "nodejs14.x"
  handler = "hello.handler"

  source_code_hash = data.archive_file.lambda_hello_world.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "hello_world" {
  name = "/aws/lambda/${aws_lambda_function.hello_world.function_name}"

  retention_in_days = 30
}

resource "aws_lambda_function" "inspect_data" {
  function_name = "InspectData"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_hello_world.key

  runtime = "nodejs14.x"
  handler = "analysis.handler"
  timeout = 30

  source_code_hash = data.archive_file.lambda_hello_world.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "inspect_data" {
  name = "/aws/lambda/${aws_lambda_function.inspect_data.function_name}"

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
        Action = [ "s3:GetObject", ]
        Effect   = "Allow"
        Resource = [ "${aws_s3_bucket.data_bucket.arn}/*" ]
      },
      {
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload",
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
