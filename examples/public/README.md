# SImple Public SFTP example

This example creates a simple public facing AWS Transfer for SFTP service using the API_GATEWAY identity provider. 

A bucket will be created to store the files along with an IAM role for the user to access the service.

## Usage

    $ terraform init
    $ terraform plan
    $ terraform apply


## Example User Configuration

Once the service has been started, a user can be set up by adding a record to the DynamoDB table as follows:

NOTE: All fields are ***String*** fields including the ***HomeDirectoryDetails*** which should contain a JSON string


| UserId | HomeDirectoryDetails | Role | Password |
|--------|----------------------|------|----------|
| user1 | [{\"Entry\": \"/\", \"Target\": \"/test.devopsgoat/${Transfer:UserName}\"}] | arn:aws:iam::218071597196:role/transfer-user-iam-role | Password1 |

This will create a user **user1** which is chroot'd to the **/test.devopsgoat/user1** virtual directory in S3.


## Outputs

| Name | Description |
|------|-------------|
| sftp-endpoint | The endpoint of the SFTP service |

