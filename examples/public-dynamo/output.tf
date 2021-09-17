output "endpoint" {
  value = aws_transfer_server.sftp.endpoint
}

output "role" {
  value = aws_iam_role.foo.arn
}

