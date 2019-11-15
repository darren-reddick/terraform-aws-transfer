# terraform-aws-transfer
Terraform Module for a custom identity provider for the AWS Transfer for SFTP service.  

This module aims to set up an identity provider built on:
* API Gateway
* Lambda
* DynamoDB

This module will output the URL for the API Gateway which should be used as the ***url*** argument for the ***aws_transfer_server*** resource

A DynamoDB table will be created by the resource and is used to store SFTP user credentials and user directory details.

The infrastructure code is based on the example provided (in the CF template) in the AWS Storage Blog article https://aws.amazon.com/blogs/storage/enable-password-authentication-for-aws-transfer-for-sftp-using-aws-secrets-manager/. That example uses AWS Secrets Manager which costs $0.40 per Secret so a DynamoDB based solution may be more palatable as having many users may incur high costs.

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
- [Use public Transfer service](https://github.com/devopsgoat/terraform-aws-transfer/tree/master/examples/public)
    * This example creates an SFTP service, a bucket for storage and an IAM role for the user along with the API Gateway IdP


## Terraform Versions
This module supports Terraform v0.12


