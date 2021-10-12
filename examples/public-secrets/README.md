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

For guidance the following example code will create this Secret:

```
resource "aws_secretsmanager_secret" "secret" {
  name = "SFTP/user1"
}

resource "aws_secretsmanager_secret_version" "secret" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = <<-POLICY
    {
      "HomeDirectoryDetails": "[{\"Entry\": \"/\", \"Target\": \"/${aws_s3_bucket.sftp.id}/$${Transfer:UserName}\"}]",
      "Password": "Password1",
      "Role": "${aws_iam_role.foo.arn}",
      "UserId": "user1"
    }
  POLICY
}
```

The user would connect with

```
sftp user1@<endpoint>
```

## Outputs

| Name | Description |
|------|-------------|
| endpoint | The endpoint of the SFTP service |
| role | The IAM Role that must be assigned to users |
