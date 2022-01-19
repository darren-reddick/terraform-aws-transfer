resource "aws_secretsmanager_secret" "secret" {
  for_each                = local.tests
  name                    = "SFTP/${each.value.UserId}"
  recovery_window_in_days = 0
}

resource "random_password" "password" {
  for_each = local.tests

  length           = 16
  special          = true
  override_special = "_%@"
}

resource "aws_secretsmanager_secret_version" "secret" {
  for_each = local.tests

  secret_id     = aws_secretsmanager_secret.secret[each.key].id
  secret_string = <<-EOF
    {
      "HomeDirectoryDetails": "[{\"Entry\": \"/\", \"Target\": \"/${aws_s3_bucket.sftp.id}/$${Transfer:UserName}\"}]",
      "Password": "${random_password.password[each.key].result}",
      "Role": "${aws_iam_role.transfer.arn}",
      "UserId": "${each.value.UserId}"
    }
  EOF
}




