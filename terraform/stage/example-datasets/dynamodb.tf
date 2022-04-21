resource "random_uuid" "user_id" {}
resource "random_uuid" "dataset_id_gnad" {}
resource "random_uuid" "dataset_id_imdb" {}
resource "random_uuid" "dataset_id_mnist" {}
resource "time_static" "created_at_gnad" {}
resource "time_static" "created_at_imdb" {}
resource "time_static" "created_at_mnist" {}

resource "aws_dynamodb_table_item" "dataset_gnad" {
  table_name = data.terraform_remote_state.s3.outputs.dynamodb_datasets_table_name
  hash_key   = data.terraform_remote_state.s3.outputs.dynamodb_datasets_table_hash_key
  range_key  = data.terraform_remote_state.s3.outputs.dynamodb_datasets_table_range_key

  item = jsonencode({
    user_id = { S = random_uuid.user_id.result }
    created_at = { S = time_static.created_at_gnad.rfc3339 }
    dataset_id = { S = random_uuid.dataset_id_gnad.result }
    dataset_slug = { S = "gnad10k" }
    dataset_name = { S = "German News Articles" }
    dataset_type = { S = "text" }
    dataset_description = { S = "The 10k German News Article Dataset consists of 10273 German language news articles from the online Austrian newspaper website DER Standard. Each news article has been classified into one of 9 categories by professional forum moderators employed by the newspaper. This dataset is extended from the original One Million Posts Corpus. The dataset was created to support topic classification in German because a classifier effective on a English dataset may not be as effective on a German dataset due to higher inflections and longer compound words. Additionally, this dataset can be used as a benchmark dataset for German topic classification." }
    dataset_websites = {
      L = [
        { S = ""}
      ]
    }
    urls = {
      M = {
        train = { S = "https://raw.githubusercontent.com/tblock/10kGNAD/master/train.csv" }
        test  = { S = "https://raw.githubusercontent.com/tblock/10kGNAD/master/test.csv" }
      }
    }
  })
}

resource "aws_dynamodb_table_item" "dataset_imdb" {
  table_name = data.terraform_remote_state.s3.outputs.dynamodb_datasets_table_name
  hash_key   = data.terraform_remote_state.s3.outputs.dynamodb_datasets_table_hash_key
  range_key  = data.terraform_remote_state.s3.outputs.dynamodb_datasets_table_range_key

  item = jsonencode({
    user_id = { S = random_uuid.user_id.result }
    created_at = { S = time_static.created_at_imdb.rfc3339 }
    dataset_id = { S = random_uuid.dataset_id_imdb.result }
    dataset_slug = { S = "imdb" }
    dataset_name = { S = "IMDB Large Movie Review Dataset" }
    dataset_type = { S = "text" }
    dataset_description = { S = "" }
    dataset_websites = {
      L = [
        { S = ""}
      ]
    }
    urls = {
      M = {
        train = { S = "" }
        test  = { S = "" }
      }
    }
  })
}

resource "aws_dynamodb_table_item" "dataset_mnist" {
  table_name = data.terraform_remote_state.s3.outputs.dynamodb_datasets_table_name
  hash_key   = data.terraform_remote_state.s3.outputs.dynamodb_datasets_table_hash_key
  range_key  = data.terraform_remote_state.s3.outputs.dynamodb_datasets_table_range_key

  item = jsonencode({
    user_id = { S = random_uuid.user_id.result }
    created_at = { S = time_static.created_at_mnist.rfc3339 }
    dataset_id = { S = random_uuid.dataset_id_mnist.result }
    dataset_slug = { S = "mnist" }
    dataset_name = { S = "MNIST" }
    dataset_type = { S = "image" }
    dataset_description = { S = "" }
    dataset_websites = {
      L = [
        { S = "http://yann.lecun.com/exdb/mnist/"},
        { S = "https://huggingface.co/datasets/mnist"}
      ]
    }
    urls = {
      M = {
        train = { S = "" }
        test  = { S = "" }
      }
    }
  })
}
