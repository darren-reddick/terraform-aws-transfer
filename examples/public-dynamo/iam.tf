resource "aws_iam_role" "foo" {
  name = "transfer-user-iam-role"

  assume_role_policy = <<-POLICY
    {
        "Version": "2012-10-17",
        "Statement": [
            {
            "Effect": "Allow",
            "Principal": {
                "Service": "transfer.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
            }
        ]
    }
  POLICY
}

resource "aws_iam_role_policy" "foo" {
  name = "transfer-user-iam-policy"
  role = aws_iam_role.foo.id

  policy = <<-POLICY
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "AllowListingOfUserFolder",
                "Action": [
                    "s3:ListBucket",
                    "s3:GetBucketLocation"
                ],
                "Effect": "Allow",
                "Resource": [
                    "${aws_s3_bucket.sftp.arn}"
                ]
            },
            {
                "Sid": "HomeDirObjectAccess",
                "Effect": "Allow",
                "Action": [
                    "s3:PutObject",
                    "s3:GetObject",
                    "s3:DeleteObjectVersion",
                    "s3:DeleteObject",
                    "s3:GetObjectVersion"
                ],
                "Resource": ["${aws_s3_bucket.sftp.arn}","${aws_s3_bucket.sftp.arn}/*"]
            }
        ]
    }
  POLICY
}
