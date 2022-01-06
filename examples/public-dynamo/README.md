# Simple Public SFTP example using DynamoDB

This example creates a simple public facing AWS Transfer for SFTP service using the API_GATEWAY identity provider.

A bucket will be created to store the files along with an IAM role for the user to access the service.

## Usage

    $ terraform init
    $ terraform plan
    $ terraform apply

## Example User Configuration

Once the service has been started, a user can be set up by adding a record to the DynamoDB table as follows:

NOTE: All fields are ***String*** fields including the ***HomeDirectoryDetails*** which should contain a JSON string

| UserId | HomeDirectoryDetails | Role | Password | _AcceptedIpNetwork*_ |
|--------|----------------------|------|----------|-------------------|
| user1 | [{\"Entry\": \"/\", \"Target\": \"/test.devopsgoat/${Transfer:UserName}\"}] | arn:aws:iam::[account id]:role/transfer-user-iam-role | Password1 | 192.168.1.0/24 |

This will create a user **user1** which is chroot'd to the **/test.devopsgoat/user1** virtual directory in S3.

\* **_AcceptedIpNetwork_** is an optional CIDR for the allowed client source IP address range.

### Create User with a Password
```bash
aws dynamodb put-item \
  --table-name my-sftp-authentication-table \
  --item '{"UserId": {"S": "user1"}, "HomeDirectoryDetails": {"L": [{"M": {"Entry": {"S": "/"}, "Target": {"S": "/test.devopsgoat/${Transfer:UserName}"}}}]}, "Role": {"S": "arn:aws:iam::[account id]:role/transfer-user-iam-role"}, "Password": {"S": "Password1"}}'
```

#### Authenticate

```bash
sftp user1@<aws_transfer_server.sftp.endpoint>
```

### Create a User with an SSH Key

Replace the `PublicKey` value below:

```bash
aws dynamodb put-item \
  --table-name my-sftp-authentication-table \
  --item '{"UserId": {"S": "user1"}, "HomeDirectoryDetails": {"L": [{"M": {"Entry": {"S": "/"}, "Target": {"S": "/test.devopsgoat/${Transfer:UserName}"}}}]}, "Role": {"S": "arn:aws:iam::[account id]:role/transfer-user-iam-role"}, "PublicKey": { "S": "ssh-rsa ... must be a valid rsa public key" }}'
```

#### Authenticate
The identity must be explicitly declared

```bash
sftp -i ~/.ssh/id_rsa user1@<aws_transfer_server.sftp.endpoint>
```

## Outputs

| Name | Description |
|------|-------------|
| dynamo_table_name | The DynamoDB table name to be used in `--table-name` |
| endpoint | The endpoint of the SFTP service |
| role | The IAM Role that must be assigned to users |
