terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.1"
    }
  }

  required_version = ">= 0.14.9"

  backend "s3" {
    bucket         = "tft-terraform-state"
    key            = "stage/services/lambdas/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "tft-terraform-state-locks"
    encrypt        = true
  }
}

provider "aws" {
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

data "terraform_remote_state" "athena" {
  backend = "s3"
  config = {
    bucket = "tft-terraform-state"
    key    = "stage/services/athena/terraform.tfstate"
    region = "eu-central-1"
  }
}
