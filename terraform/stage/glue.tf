resource "aws_glue_catalog_database" "datasets_db" {
  # underscores (_) are the only special characters that Athena supports in database, table, view, and column names.
  # https://aws.amazon.com/premiumsupport/knowledge-center/parse-exception-missing-eof-athena/
  name = "datasets_db"
}

resource "aws_glue_catalog_table" "gnad_train" {
  database_name = aws_glue_catalog_database.datasets_db.name
  name          = "gnad_train"
  description   = "GNAD10k training data"

  table_type = "EXTERNAL"  // needed by Athena?

  parameters = {
    EXTERNAL = "TRUE"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.data_bucket.id}/gnad/train"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = "CSV format parser"
      serialization_library = "org.apache.hadoop.hive.serde2.OpenCSVSerde"

      parameters = {
        "separatorChar" = ";"
        "quoteChar" = "'"
        "serialization.format" = 1  // needed by Athena
      }
    }

    columns {
      name = "label"
      type = "string"
    }

    columns {
      name = "text"
      type = "string"
    }
  }
}

resource "aws_glue_catalog_table" "gnad_test" {
  database_name = aws_glue_catalog_database.datasets_db.name
  name          = "gnad_test"
  description   = "GNAD10k test data"

  table_type = "EXTERNAL"  // needed by Athena?

  parameters = {
    EXTERNAL = "TRUE"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.data_bucket.id}/gnad/test"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = "CSV format parser"
      serialization_library = "org.apache.hadoop.hive.serde2.OpenCSVSerde"

      parameters = {
        "separatorChar" = ";"
        "quoteChar" = "'"
        "serialization.format" = 1  // needed by Athena
      }
    }

    columns {
      name = "label"
      type = "string"
    }

    columns {
      name = "text"
      type = "string"
    }
  }
}
