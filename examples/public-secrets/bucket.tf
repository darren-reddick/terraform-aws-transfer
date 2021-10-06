resource "aws_s3_bucket" "sftp" {
  bucket_prefix = "sftpbucket"
  acl           = "private"
}