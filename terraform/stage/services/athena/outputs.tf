output "glue_catalog_database_arn" {
  description = "ARN of the Glue catalog database."
  value = aws_glue_catalog_database.datasets_db.arn
}

output "glue_catalog_database_name" {
  description = "Name of the Glue catalog database."
  value = aws_glue_catalog_database.datasets_db.name
}

output "athena_workgroup_arn" {
  description = "ARN of the athena workgroup."
  value = aws_athena_workgroup.athena_workgroup.arn
}
