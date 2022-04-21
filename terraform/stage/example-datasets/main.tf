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
    key            = "stage/example-datasets/terraform.tfstate"
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

# Upload and configure a training and a test dataset

module "gnad_train" {
  source = "../../modules/glue_dataset"

  bucket_name          = data.terraform_remote_state.s3.outputs.datasets_bucket_name
  dataset_key          = "gnad/train"
  dataset_filename     = "train.csv"
  source_file          = "../../../data/gnad/train.csv"
  database_name        = data.terraform_remote_state.athena.outputs.glue_catalog_database_name
  table_name           = "gnad_train"
  table_description    = "GNAD10k training data"
  quote_char           = "'"
  separator_char       = ";"
  columns = {
    label     = "string"
    text      = "string"
  }
}

module "gnad_test" {
  source = "../../modules/glue_dataset"

  bucket_name          = data.terraform_remote_state.s3.outputs.datasets_bucket_name
  dataset_key          = "gnad/test"
  dataset_filename     = "test.csv"
  source_file          = "../../../data/gnad/test.csv"
  database_name        = data.terraform_remote_state.athena.outputs.glue_catalog_database_name
  table_name           = "gnad_test"
  table_description    = "GNAD10k test data"
  quote_char           = "'"
  separator_char       = ";"
  columns = {
    label     = "string"
    text      = "string"
  }
}
