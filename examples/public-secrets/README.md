# Simple Public SFTP example using AWS Secrets

This example creates a simple public facing AWS Transfer for SFTP service using the API_GATEWAY identity provider using AWS Secrets as the cred store.

A bucket will be created to store the files along with an IAM role for the user to access the service.

## Usage

    $ terraform init
    $ terraform plan
    $ terraform apply


## Example User Configuration

Once the service has been started, a user can be set up by adding an AWS Secret:

The secret name should be SFTP/user1 for a user login **user1**


| UserId | HomeDirectoryDetails | Role | Password |
|--------|----------------------|------|----------|
| user1 | [{\"Entry\": \"/\", \"Target\": \"/test.devopsgoat/${Transfer:UserName}\"}] | arn:aws:iam::[account id]:role/transfer-user-iam-role | Password1 |

This will create a user **user1** which is chroot'd to the **/test.devopsgoat/user1** virtual directory in S3.


## Outputs

| Name | Description |
|------|-------------|
| sftp-endpoint | The endpoint of the SFTP service |

