terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  required_version = ">= 0.14.9"

  backend "s3" {
    bucket         = "tft-terraform-state"
    key            = "stage/services/athena/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "tft-terraform-state-locks"
    encrypt        = true
  }
}

provider "aws" {
  profile = "default"
  region  = var.region

  default_tags {
    tags = {
      Project     = "Athena Data Analysis"
    }
  }
}

data "aws_caller_identity" "current" {}


data "terraform_remote_state" "s3" {
  backend = "s3"
  config = {
    bucket = "tft-terraform-state"
    key    = "stage/data-storage/terraform.tfstate"
    region = "eu-central-1"
  }
}

# Athena workgroup configuration
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
        kms_key_arn       = data.terraform_remote_state.s3.outputs.s3_kms_key_arn  # KMS master key to use
      }
    }
  }
}

# Glue configuration
resource "aws_glue_catalog_database" "datasets_db" {
  # underscores (_) are the only special characters that Athena supports in database, table, view, and column names.
  # https://aws.amazon.com/premiumsupport/knowledge-center/parse-exception-missing-eof-athena/
  name = "datasets_db"
}

resource "aws_glue_data_catalog_encryption_settings" "datasets_db" {
  data_catalog_encryption_settings {
    connection_password_encryption {
      aws_kms_key_id                       = data.terraform_remote_state.s3.outputs.s3_kms_key_arn
      return_connection_password_encrypted = true
    }

    encryption_at_rest {
      catalog_encryption_mode = "SSE-KMS"
      sse_aws_kms_key_id      = data.terraform_remote_state.s3.outputs.s3_kms_key_arn
    }
  }
}
