resource "aws_s3_bucket" "data_bucket" {
  bucket = var.dataset_bucket_name
}

resource "aws_s3_bucket_acl" "data_bucket" {
  bucket = aws_s3_bucket.data_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data_bucket" {
  bucket = aws_s3_bucket.data_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      #kms_master_key_id = aws_kms_key.s3_key.arn  # otherwise use default aws/s3 AWS KMS master key
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "data_bucket" {
  bucket = aws_s3_bucket.data_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "gnad_train" {
  bucket = aws_s3_bucket.data_bucket.id
  key    = "gnad/train/train.csv"
  source = "../data/gnad/train.csv"
}

resource "aws_s3_object" "gnad_test" {
  bucket = aws_s3_bucket.data_bucket.id
  key    = "gnad/test/test.csv"
  source = "../data/gnad/test.csv"
}

resource "aws_s3_bucket" "athena_results_bucket" {
  bucket = var.athena_results_bucket_name
}

resource "aws_s3_bucket_lifecycle_configuration" "athena_results_bucket" {
  bucket = aws_s3_bucket.athena_results_bucket.id

  rule {
    id = "athena_results_expiration"
    status = "Enabled"
    expiration {
      days = 7
    }
  }
}

resource "aws_s3_bucket_acl" "athena_results_bucket" {
  bucket = aws_s3_bucket.athena_results_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "athena_results_bucket" {
  bucket = aws_s3_bucket.athena_results_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      #kms_master_key_id = aws_kms_key.s3_key.arn  # otherwise use default aws/s3 AWS KMS master key
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "athena_results_bucket" {
  bucket = aws_s3_bucket.athena_results_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = var.lambda_bucket_name
}

resource "aws_s3_bucket_acl" "lambda_bucket" {
  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lambda_bucket" {
  bucket = aws_s3_bucket.lambda_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      #kms_master_key_id = aws_kms_key.s3_key.arn  # otherwise use default aws/s3 AWS KMS master key
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "lambda_bucket" {
  bucket = aws_s3_bucket.lambda_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


