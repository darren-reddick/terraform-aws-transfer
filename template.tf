data "template_file" "api-definition" {
  template = file("${path.module}/api-definitions/openapi.yaml")

  vars = {
    LAMBDA_INVOKE_ARN           = aws_lambda_function.sftp-idp.invoke_arn
  }
}