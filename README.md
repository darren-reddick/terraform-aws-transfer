# terraform-aws-transfer
Terraform Module for a custom identity provider for the AWS Transfer for SFTP service.  

This module aims to set up an identity provider built on:
* API Gateway
* Lambda
* DynamoDB

This module will output the URL for the API Gateway which should be used as the ***url*** argument for the ***aws_transfer_server*** resource

A DynamoDB table will be created by the resource

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| dynamo_table_name | A name for the dynamodb table that will be created | string |  | yes |

## Outputs

| Name | Description |
|------|-------------|
| invoke_url | The URL which the SFTP service will use to send authentication requests to |
| rest_api_id | The ARN of the REST service created. <br>This should be used in the IAM role for SFTP to invoke the service |

## Usage
```hcl-terraform
module "sftp-idp" {
  source                = "../.."
  dynamo_table_name      = "my-sftp-authentication-table"
}
```


## Examples



## Terraform Versions
This module supports Terraform v0.11 from v0.0.1
Terraform v0.12 support is coming soon...


## Notes
