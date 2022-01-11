resource "aws_s3_bucket" "sftp" {
  bucket = local.bucket_name
  acl    = "private"

}