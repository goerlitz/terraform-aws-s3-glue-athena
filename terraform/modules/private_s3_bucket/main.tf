resource "aws_s3_bucket" "private_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_acl" "private_bucket" {
  bucket = aws_s3_bucket.private_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "private_bucket" {
  bucket = aws_s3_bucket.private_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      #kms_master_key_id = aws_kms_key.s3_key.arn  # otherwise use default aws/s3 AWS KMS master key
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "private_bucket" {
  bucket = aws_s3_bucket.private_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "private_bucket" {
  count = var.expiration_days > 0 ? 1 : 0
  bucket = aws_s3_bucket.private_bucket.id

  rule {
    id = "${aws_s3_bucket.private_bucket.id}_expiration"
    status = "Enabled"
    expiration {
      days = var.expiration_days
    }
  }
}

resource "aws_s3_bucket_policy" "private_bucket_policy" {
  bucket = aws_s3_bucket.private_bucket.id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      { # s3-bucket-ssl-requests-only rule
        # https://aws.amazon.com/premiumsupport/knowledge-center/s3-bucket-policy-for-config-rule/
        Sid: "AllowSSLRequestsOnly",
        Action: "s3:*",
        Effect: "Deny",
        Resource: [
          aws_s3_bucket.private_bucket.arn,
          "${aws_s3_bucket.private_bucket.arn}/*",
        ],
        Condition: {
          Bool: {
            "aws:SecureTransport": "false"
          }
        },
        Principal: "*"
      }
    ]
  })
}
