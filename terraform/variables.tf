variable "region" {
  description = "AWS region."
  type        = string
  default     = "eu-central-1"
}

variable "dataset_bucket_name" {
  description = "Name of the S3 bucket that contains the datasets."
  type        = string
  default     = "tft-dataset-storage"
}

variable "athena_results_bucket_name" {
  description = "Name of the S3 bucket that Athena uses for query results."
  type        = string
  default     = "tft-athena-query-results"
}
