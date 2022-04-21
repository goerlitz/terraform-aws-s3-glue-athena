terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    random = {
      source = "hashicorp/random"
      version = "~> 3.1.2"
    }
    time = {
      source = "hashicorp/time"
      version = "~> 0.7.2"
    }
  }

  required_version = ">= 0.14.9"

  backend "s3" {
    bucket         = "tft-terraform-state"
    key            = "stage/data-stores/terraform.tfstate"
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
      Project      = "Athena Data Analysis"
    }
  }
}

data "aws_caller_identity" "current" {}

module "s3_data_bucket" {
  source = "../../modules/private_s3_bucket"
  bucket_name = var.dataset_bucket_name
}

module "s3_athena_results_bucket" {
  source = "../../modules/private_s3_bucket"
  bucket_name = var.athena_results_bucket_name
  expiration_days = 7
}

module "s3_lambda_bucket" {
  source = "../../modules/private_s3_bucket"
  bucket_name = var.lambda_bucket_name
}

# Access Patterns
# * Get all datasets of a user
# * Get details of a specific dataset (of a user)
# * Update details of a specific dataset (of a user)

resource "aws_dynamodb_table" "datasets" {
  name         = "tft-datasets"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"
  range_key    = "dataset_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "dataset_id"
    type = "S"
  }

  server_side_encryption {
    enabled = true
    kms_key_arn = aws_kms_key.s3_key.arn
  }
}
