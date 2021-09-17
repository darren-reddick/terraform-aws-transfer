resource "aws_iam_role" "iam_for_apigateway_idp" {
  name = "iam_for_apigateway_idp"

  assume_role_policy = <<-EOF
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
  EOF
}


resource "aws_iam_role_policy_attachment" "apigateway-cloudwatchlogs" {
  role       = aws_iam_role.iam_for_apigateway_idp.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_account" "eu-west-1" {
  cloudwatch_role_arn = aws_iam_role.iam_for_apigateway_idp.arn
}

resource "aws_api_gateway_rest_api" "sftp-idp-secrets" {
  name        = "sftp-idp-secrets"
  description = "This API provides an IDP for AWS Transfer service"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "sftp-idp-secrets-resource-config" {
  rest_api_id = aws_api_gateway_rest_api.sftp-idp-secrets.id
  parent_id   = aws_api_gateway_resource.sftp-idp-secrets-resource-username.id
  path_part   = "config"
}

resource "aws_api_gateway_resource" "sftp-idp-secrets-resource-username" {
  rest_api_id = aws_api_gateway_rest_api.sftp-idp-secrets.id
  parent_id   = aws_api_gateway_resource.sftp-idp-secrets-resource-users.id
  path_part   = "{username}"
}

resource "aws_api_gateway_resource" "sftp-idp-secrets-resource-users" {
  rest_api_id = aws_api_gateway_rest_api.sftp-idp-secrets.id
  parent_id   = aws_api_gateway_resource.sftp-idp-secrets-resource-serverid.id
  path_part   = "users"
}

resource "aws_api_gateway_resource" "sftp-idp-secrets-resource-serverid" {
  rest_api_id = aws_api_gateway_rest_api.sftp-idp-secrets.id
  parent_id   = aws_api_gateway_resource.sftp-idp-secrets-resource-servers.id
  path_part   = "{serverId}"
}

resource "aws_api_gateway_resource" "sftp-idp-secrets-resource-servers" {
  rest_api_id = aws_api_gateway_rest_api.sftp-idp-secrets.id
  parent_id   = aws_api_gateway_rest_api.sftp-idp-secrets.root_resource_id
  path_part   = "servers"
}

resource "aws_api_gateway_method" "sftp-idp-secrets-method" {
  rest_api_id   = aws_api_gateway_rest_api.sftp-idp-secrets.id
  resource_id   = aws_api_gateway_resource.sftp-idp-secrets-resource-config.id
  http_method   = "GET"
  authorization = "AWS_IAM"
  request_parameters = {
    "method.request.header.Password" = "false"
  }
}

resource "aws_api_gateway_integration" "sftp-idp-secrets-integration" {
  rest_api_id             = aws_api_gateway_rest_api.sftp-idp-secrets.id
  resource_id             = aws_api_gateway_resource.sftp-idp-secrets-resource-config.id
  http_method             = "GET"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.sftp-idp.invoke_arn
  depends_on              = [null_resource.method-delay]


  # Transforms the incoming XML request to JSON
  request_templates = {
    "application/json" = <<-EOF
      {
        "username": "$input.params('username')",
        "password": "$util.escapeJavaScript($input.params('Password')).replaceAll("\\'","'")",
        "serverId": "$input.params('serverId')"
      }
    EOF
  }
}

resource "aws_api_gateway_method_response" "sftp-idp-secrets-response_200" {
  rest_api_id = aws_api_gateway_rest_api.sftp-idp-secrets.id
  resource_id = aws_api_gateway_resource.sftp-idp-secrets-resource-config.id
  http_method = "GET"
  status_code = "200"

  response_models = {
    "application/json" = aws_api_gateway_model.sftp-idp-secrets-model.name
  }
  depends_on = [null_resource.method-delay]
}

resource "aws_api_gateway_integration_response" "sftp-idp-secrets-method-IntegrationResponse" {
  rest_api_id = aws_api_gateway_rest_api.sftp-idp-secrets.id
  resource_id = aws_api_gateway_resource.sftp-idp-secrets-resource-config.id
  http_method = aws_api_gateway_method.sftp-idp-secrets-method.http_method
  status_code = aws_api_gateway_method_response.sftp-idp-secrets-response_200.status_code
  # depends_on = [null_resource.method-delay]
}

resource "aws_api_gateway_model" "sftp-idp-secrets-model" {
  rest_api_id  = aws_api_gateway_rest_api.sftp-idp-secrets.id
  name         = "UserConfigResponseModel"
  description  = "API response for GetUserConfig"
  content_type = "application/json"

  schema = <<-EOF
    {
      "$schema": "http://json-schema.org/draft-04/schema#",
      "title": "UserUserConfig",
      "type": "object",
      "properties" : {
        "HomeDirectory": {"type": "string"},
        "Role": {"type": "string"},
        "Policy": {"type": "string"},
        "PublicKeys": {"type": "array", "items" : {"type" : "string"}}
      }
    }
  EOF
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
  stage_name  = ""

  depends_on  = [
    aws_api_gateway_integration.sftp-idp-secrets-integration
  ]

  variables = {
    deployed_at = timestamp()
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

# introduce delay to let things settle down to fix 404 issue creating some resources
resource "null_resource" "method-delay" {
  provisioner "local-exec" {
    command = "sleep 20"
  }

  triggers = {
    rest_api_id = aws_api_gateway_rest_api.sftp-idp-secrets.id
    resource_id = aws_api_gateway_resource.sftp-idp-secrets-resource-config.id
  }
}
