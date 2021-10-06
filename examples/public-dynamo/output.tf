output "dynamo_table_name" {
  value = module.idp.dynamo_table_name
}

output "endpoint" {
  value = aws_transfer_server.sftp.endpoint
}

output "role" {
  value = aws_iam_role.foo.arn
}
