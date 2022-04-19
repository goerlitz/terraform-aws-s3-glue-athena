variable "function_name" {
  description = "Name of the lambda function."
  type        = string
}

variable "function_handler" {
  description = "Name of the lambda function handler."
  type        = string
}

variable "function_url" {
  description = "HTTP method and url for this api function."
  type        = string
}

variable "function_timeout" {
  description = "Function timeout in seconds."
  type        = number
  default     = 60
}

variable "source_code_bucket" {
  description = "Name of the s3 bucket with the lambda function code."
  type        = string
}

variable "source_code_key" {
  description = "S3 key of the zip file with the lambda function code."
  type        = string
}

variable "source_code_hash" {
  description = "Base64sha256 hash of the zip archive."
  type        = string
}

variable "s3_kms_key_arn" {
  description = "ARN of the encryption key."
  type        = string
}

variable "lambda_iam_role_arn" {
  description = "ARN of the lambda iam role."
  type        = string
}

variable "lambda_api_id" {
  description = "ID/name of the lambda api."
  type        = string
}

variable "lambda_api_exec_arn" {
  description = "ARN of the lambda api execution."
  type        = string
}
