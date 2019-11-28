# terraform-aws-transfer
Terraform Module to create a custom identity provider for the AWS Transfer for SFTP service.  

This module aims to set up an identity provider built on:
* API Gateway
* Lambda
* DynamoDB or AWS Secrets

This module will output the URL for the API Gateway which should be used as the ***url*** argument for the ***aws_transfer_server*** resource

## Credential Store

A DynamoDB table will be created by the resource and can be used to store SFTP user credentials and user directory details.

Alternatively for security, the credentials can be stored as AWS Secrets.

The infrastructure code is based on the example provided (in the CF template) in the AWS Storage Blog article https://aws.amazon.com/blogs/storage/enable-password-authentication-for-aws-transfer-for-sftp-using-aws-secrets-manager/. That example uses AWS Secrets Manager which costs $0.40 per Secret so a DynamoDB based solution may be more palatable as having many users may incur high costs on smaller budgets.

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

## Usage
```hcl-terraform
module "sftp-idp" {
  source                = "../.."
  dynamo_table_name      = "my-sftp-authentication-table"
}
```


## Examples

* [Public with Dynamo](https://github.com/devopsgoat/terraform-aws-transfer/tree/master/examples/public-dynamo)
* [Public with AWS Secrets](https://github.com/devopsgoat/terraform-aws-transfer/tree/master/examples/private-dynamo)

## Known Issues

### API Gateway Deployment

On subsequent application of changes to the infrastructure Terraform detects a change in the API Gateway deployment. The update will then fail with the following message:

> Error: error deleting API Gateway Deployment (p9qtq5): BadRequestException: Active stages pointing to this deployment must be moved or deleted
>         status code: 400, request id: 278c5cb7-5cf7-4628-8604-d924edd0f145

The workaround for this is to taint the stage which uses the deployment before applying the infrastructure change - example:

    terraform taint module.idp.aws_api_gateway_stage.prod

## Terraform Versions
This module supports Terraform v0.12


