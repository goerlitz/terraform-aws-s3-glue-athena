# Create a custom managed key to encrypt s3 buckets.
# Important, lambda functions need to be granted access to use the key.

resource "aws_kms_key" "s3_key" {
  description             = "This key is used to encrypt s3 bucket objects"
  deletion_window_in_days = 10
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
