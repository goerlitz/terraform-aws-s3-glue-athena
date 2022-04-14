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
