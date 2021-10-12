resource "aws_s3_bucket" "sftp" {
  bucket_prefix = "test.devopsgoat"
  acl           = "private"
}
