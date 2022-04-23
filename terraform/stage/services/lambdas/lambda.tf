# https://aws.amazon.com/premiumsupport/knowledge-center/access-denied-athena/
# https://aws.amazon.com/premiumsupport/knowledge-center/athena-output-bucket-error/

#resource "null_resource" "lambda_zip_prep" {
#
#  triggers = {
#    # for i in $(find dist -maxdepth 2 -type f | sort); do md5sum "${i}"; done | md5sum
#     always_run = timestamp()
#    # https://stackoverflow.com/questions/51138667/can-terraform-watch-a-directory-for-changes
##    dir_sha1 = sha1(join("", [for f in fileset("dist", "*"): filesha1(f)]))
#  }
#
#  provisioner "local-exec" {
#    command = join(" && ", [
#      "rm -rf ${path.module}/../../../../dist/data-api/node_modules",
#      "cp -r ${path.module}/../../../../node_modules ${path.module}/../../../../dist/data-api/node_modules"
#    ])
#  }
#}

data "archive_file" "lambda_data_api" {
  type = "zip"

  source_dir  = "${path.module}/../../../../build"
  output_path = "${path.module}/../../../../dist-aws/data-api.zip"

#  depends_on = [null_resource.lambda_zip_prep]
}

resource "aws_s3_object" "lambda_dist" {
  bucket = data.terraform_remote_state.s3.outputs.lambda_bucket_name
  key    = "data-api.zip"
  source = data.archive_file.lambda_data_api.output_path
  etag = data.archive_file.lambda_data_api.output_md5
}

module "lambda_api_inspect" {
  source = "../../../modules/lambda_api_gateway"

  function_handler     = "analysis.handler"
  function_name        = "Inspect"
  function_url         = "POST /inspect"
  lambda_iam_role_arn  = aws_iam_role.lambda_exec.arn
  s3_kms_key_arn       = data.terraform_remote_state.s3.outputs.s3_kms_key_arn
  source_code_bucket   = data.terraform_remote_state.s3.outputs.lambda_bucket_name
  source_code_key      = aws_s3_object.lambda_dist.key
  source_code_hash     = data.archive_file.lambda_data_api.output_base64sha256

  lambda_api_id        =  aws_apigatewayv2_api.lambda_api.id
  lambda_api_exec_arn  =  aws_apigatewayv2_api.lambda_api.execution_arn
}

module "lambda_api_download" {
  source = "../../../modules/lambda_api_gateway"

  function_handler     = "download.handler"
  function_name        = "Download"
  function_url         = "POST /download"
  lambda_iam_role_arn  = aws_iam_role.lambda_exec.arn
  s3_kms_key_arn       = data.terraform_remote_state.s3.outputs.s3_kms_key_arn
  source_code_bucket   = data.terraform_remote_state.s3.outputs.lambda_bucket_name
  source_code_key      = aws_s3_object.lambda_dist.key
  source_code_hash     = data.archive_file.lambda_data_api.output_base64sha256

  lambda_api_id        =  aws_apigatewayv2_api.lambda_api.id
  lambda_api_exec_arn  =  aws_apigatewayv2_api.lambda_api.execution_arn
}

module "lambda_api_datasets" {
  source = "../../../modules/lambda_api_gateway"

  function_handler     = "datasets.handler"
  function_name        = "Datasets"
  function_url         = "GET /datasets"
  lambda_iam_role_arn  = aws_iam_role.lambda_exec.arn
  s3_kms_key_arn       = data.terraform_remote_state.s3.outputs.s3_kms_key_arn
  source_code_bucket   = data.terraform_remote_state.s3.outputs.lambda_bucket_name
  source_code_key      = aws_s3_object.lambda_dist.key
  source_code_hash     = data.archive_file.lambda_data_api.output_base64sha256

  lambda_api_id        =  aws_apigatewayv2_api.lambda_api.id
  lambda_api_exec_arn  =  aws_apigatewayv2_api.lambda_api.execution_arn
}

resource "aws_iam_role" "lambda_exec" {
  name = "LambdaExec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
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

# allow lambda to use the kms key, e.g. for writing to athena results bucket
resource "aws_kms_grant" "kms_lambda" {
  name              = "kms-lambda-grant"
  key_id            = data.terraform_remote_state.s3.outputs.s3_kms_key_name
  grantee_principal = aws_iam_role.lambda_exec.arn
  operations        = ["Encrypt", "Decrypt", "GenerateDataKey"]
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
        Resource = [ data.terraform_remote_state.s3.outputs.datasets_bucket_arn ]
      },
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
        ]
        Effect   = "Allow"
        Resource = [ "${data.terraform_remote_state.s3.outputs.datasets_bucket_arn}/*" ]
      },
      {
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
        ]
        Effect   = "Allow"
        Resource = [
          data.terraform_remote_state.s3.outputs.athena_results_bucket_arn
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
          "${data.terraform_remote_state.s3.outputs.athena_results_bucket_arn}/output/*"
        ]
      },
      {
        Action = [
          "glue:GetTable",
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:catalog",
          data.terraform_remote_state.athena.outputs.glue_catalog_database_arn,
          "${replace(data.terraform_remote_state.athena.outputs.glue_catalog_database_arn, ":database/", ":table/")}/*",
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
          data.terraform_remote_state.athena.outputs.athena_workgroup_arn
        ]
      },
      {
        # https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazondynamodb.html
        # https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/specifying-conditions.html
        Action = [
          "dynamodb:Query",
          # "dynamodb:Describe*",
          # "dynamodb:List*",
          # "dynamodb:GetItem",
          # "dynamodb:Query",
          # "dynamodb:Scan",
          # "dynamodb:PartiQLSelect",
        ]
        Effect   = "Allow"
        Resource = [
          data.terraform_remote_state.s3.outputs.dynamodb_datasets_table_arn
        ]
      },
    ]
  })
}
