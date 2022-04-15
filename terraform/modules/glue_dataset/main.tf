# An example dataset that is stored in S3 and made available via Glue.

resource "aws_s3_object" "dataset" {
  bucket = var.bucket_name
  key    = "${var.dataset_key}/${var.dataset_filename}"
  source = var.source_file
}

resource "aws_glue_catalog_table" "dataset" {
  database_name = var.database_name
  name          = var.table_name
  description   = var.table_description

  table_type = "EXTERNAL"  // needed by Athena?

  parameters = {
    EXTERNAL = "TRUE"
  }

  storage_descriptor {
    location      = "s3://${var.bucket_name}/${var.dataset_key}"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = "CSV format parser"
      serialization_library = "org.apache.hadoop.hive.serde2.OpenCSVSerde"

      parameters = {
        "separatorChar" = var.separator_char
        "quoteChar" = var.quote_char
        "serialization.format" = 1  // needed by Athena
      }
    }

    dynamic "columns" {
      for_each = var.columns
      content {
        name                 = columns.key
        type                 = columns.value
      }
    }
  }
}
