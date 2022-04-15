variable "bucket_name" {
  description = "Name of the S3 bucket that contains the datasets."
  type        = string
}

variable "dataset_key" {
  description = "Key (path name) of the dataset in the S3 bucket (with '/')."
  type        = string
}

variable "dataset_filename" {
  description = "Name of the file that is part of the dataset."
  type        = string
}

variable "source_file" {
  description = "Local filename of the dataset."
  type        = string
}

variable "database_name" {
  description = "Name of the metadata database where the table metadata resides."
  type        = string
}

variable "table_name" {
  description = "Name of the table (all lowercase)."
  type        = string
}

variable "table_description" {
  description = "Description of the table."
  type        = string
}

variable "quote_char" {
  description = "Quoting character in CSV."
  type        = string
  default     = "\""
}

variable "separator_char" {
  description = "Separator character in CSV."
  type        = string
  default     = ","
}

variable "columns" {
  description = "Names and types of the table columns."
  type        = map(string)
}
