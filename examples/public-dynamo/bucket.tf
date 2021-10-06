resource "aws_s3_bucket" "sftp" {
  bucket = "test.devopsgoat"
  acl    = "private"
}