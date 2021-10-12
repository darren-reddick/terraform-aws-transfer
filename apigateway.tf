resource "aws_iam_role" "iam_for_apigateway_idp" {
  name = "iam_for_apigateway_idp"

  assume_role_policy = <<-POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "apigateway.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        }
      ]
    }
  POLICY
}

resource "aws_iam_role_policy_attachment" "apigateway-cloudwatchlogs" {
  role       = aws_iam_role.iam_for_apigateway_idp.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_account" "api_gateway_account" {
  cloudwatch_role_arn = aws_iam_role.iam_for_apigateway_idp.arn
}

resource "aws_api_gateway_rest_api" "sftp-idp-secrets" {
  name        = "sftp-idp-secrets"
  description = "This API provides an IDP for AWS Transfer service"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  body = templatefile(
    "${path.module}/api-definitions/openapi.yaml",
    {
      LAMBDA_INVOKE_ARN = aws_lambda_function.sftp-idp.invoke_arn
    }
  )
}

resource "aws_lambda_permission" "allow_apigateway" {
  statement_id  = "AllowExecutionFromApigateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sftp-idp.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.sftp-idp-secrets.execution_arn}/*/*/*"
}

resource "aws_api_gateway_deployment" "prod" {
  rest_api_id = aws_api_gateway_rest_api.sftp-idp-secrets.id
  triggers = {
    redeployment = sha1(jsonencode([aws_api_gateway_rest_api.sftp-idp-secrets.body]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.sftp-idp-secrets.id
  deployment_id = aws_api_gateway_deployment.prod.id
}
