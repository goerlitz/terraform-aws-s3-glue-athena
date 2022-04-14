variable "bucket_name" {
  description = "Name of the S3 bucket."
  type        = string
}

variable "expiration_days" {
  description = "The lifetime, in days, of objects in the bucket."
  type        = number
  default     = 0
}