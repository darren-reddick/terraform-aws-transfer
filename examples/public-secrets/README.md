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

| UserId | HomeDirectoryDetails | Role | Password | _AcceptedIpNetwork*_ |
|--------|----------------------|------|----------|-------------------|
| user1 | [{\"Entry\": \"/\", \"Target\": \"/test.devopsgoat/${Transfer:UserName}\"}] | arn:aws:iam::[account id]:role/transfer-user-iam-role | Password1 | 192.168.1.0/24 |

This will create a user **user1** which is chroot'd to the **/test.devopsgoat/user1** virtual directory in S3.

\* **_AcceptedIpNetwork_** is an optional CIDR for the allowed client source IP address range.

For guidance the following example code will create this Secret:

```
resource "aws_secretsmanager_secret" "secret" {
  name                = "SFTP/user1"
}

resource "aws_secretsmanager_secret_version" "secret" {
  secret_id     = "${aws_secretsmanager_secret.secret.id}"
  secret_string = <<-EOF
    {
      "HomeDirectoryDetails": "[{\"Entry\": \"/\", \"Target\": \"/test.devopsgoat/$${Transfer:UserName}\"}]",
      "Password": "Password1",
      "Role": "arn:aws:iam::XXXXXXX:role/transfer-user-iam-role",
      "UserId": "user1",
      "AcceptedIpNetwork": "192.168.1.0/24",
    }
  EOF
}
```

## Outputs

| Name | Description |
|------|-------------|
| endpoint | The endpoint of the SFTP service |
| role | The IAM Role that must be assigned to users |
