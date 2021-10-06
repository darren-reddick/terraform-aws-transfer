variable "creds_store" {
  description = "If this is not `dynamo` the IdP will use the Secrets Manager for authenication."
  default     = "dynamo"
}

variable "dynamo_table_name" {
  default = "my-sftp-authentication-table"
}
