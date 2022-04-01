# Create a custom managed key to encrypt s3 buckets.
# Important, lambda functions need to be granted access to use the key.

# https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-root-enable-iam
# https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html#aws-managed-cmk

resource "aws_kms_key" "s3_key" {
  description             = "This key is used to encrypt s3 bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true  // rotates every year
}

resource "aws_kms_alias" "s3_key_alias" {
  name          = "alias/s3_key"
  target_key_id = aws_kms_key.s3_key.key_id
}

resource "aws_kms_grant" "kms_lambda" {
  name              = "kms-lambda-grant"
  key_id            = aws_kms_key.s3_key.key_id
  grantee_principal = aws_iam_role.lambda_exec.arn
  operations        = ["Encrypt", "Decrypt", "GenerateDataKey"]
}
