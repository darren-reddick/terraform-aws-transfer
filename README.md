# terraform-aws-transfer

This is a Terraform module to create a custom identity provider for the AWS Transfer for SFTP service.

This module aims to set up an identity provider built on:
* API Gateway
* Lambda
* DynamoDB

This module will output the URL for the API Gateway which should be used as the ***url*** argument for the ***aws_transfer_server*** resource

## Credential Store

A DynamoDB table will be created by the resource and can be used to store SFTP user credentials and user directory details.

Alternatively for security, the credentials can be stored as AWS Secrets.

The infrastructure code is based on the example provided (in the CF template) in the AWS Storage Blog article
https://aws.amazon.com/blogs/storage/enable-password-authentication-for-aws-transfer-family-using-aws-secrets-manager-updated//.

WARNING: AWS Secrets Manager costs $0.40 per Secret

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| dynamo_table_name | A name for the dynamodb table that will be created | string |  | yes |
| creds_store | The creds store that will be used for authentication<br>Valid should be: **dynamo** or **secrets** | string | dynamo | yes |

## Outputs

| Name | Description |
|------|-------------|
| invoke_url | The URL which the SFTP service will use to send authentication requests to |
| rest_api_id | The ARN of the REST service created. <br>This should be used in the IAM role for SFTP to invoke the service |
| rest_api_stage_name | The stage name of the REST service created. <br> This should be used in the IAM role for SFTP to invoke the service |

## Usage
```hcl-terraform
module "sftp-idp" {
  source                = "../.."
}
```

## Examples

* [Public with Dynamo](https://github.com/devopsgoat/terraform-aws-transfer/tree/master/examples/public-dynamo)
* [Public with AWS Secrets](https://github.com/devopsgoat/terraform-aws-transfer/tree/master/examples/public-secrets)

## Terraform Versions

This module supports Terraform v1.0.
