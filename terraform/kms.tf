# Create a custom managed key to encrypt s3 buckets.
# Important, lambda functions need to be granted access to use the key.

# https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-root-enable-iam
# https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html#aws-managed-cmk

resource "aws_kms_key" "s3_key" {
  description             = "This key is used to encrypt s3 bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true  // rotates every year

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # allow IAM role-based kms permissions
      {
        Sid = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = "kms:*"
        Resource = "*"
      },

      # allow key usage for CloudWatch encryption (all log-group names)
      # https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html
      {
        Effect = "Allow",
        Principal = {
          Service = "logs.${var.region}.amazonaws.com"
        },
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ],
        Resource = "*",
        Condition = {
          ArnLike = {
            "kms:EncryptionContext:aws:logs:arn": "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:*"
          }
        }
      }
    ]
  })
}

resource "aws_kms_alias" "s3_key_alias" {
  name          = "alias/s3_key"
  target_key_id = aws_kms_key.s3_key.key_id
}

# allow lambda to use this key, e.g. for writing to athena results bucket
resource "aws_kms_grant" "kms_lambda" {
  name              = "kms-lambda-grant"
  key_id            = aws_kms_key.s3_key.key_id
  grantee_principal = aws_iam_role.lambda_exec.arn
  operations        = ["Encrypt", "Decrypt", "GenerateDataKey"]
}
