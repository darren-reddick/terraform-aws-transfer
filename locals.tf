locals {
  is_dynamo         = var.creds_store == "dynamo"
  auth_source_name  = local.is_dynamo ? "dynamo_table_name" : "SecretsManagerRegion"
  auth_source_value = local.is_dynamo ? aws_dynamodb_table.authentication.name : data.aws_region.current.name
}
