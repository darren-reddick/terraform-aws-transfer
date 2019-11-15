output "endpoint" {
    value = "${aws_transfer_server.sftp.endpoint}"
}

output "redeploy" {
    value = <<EOF
${"${module.idp.redeploy}"}
EOF
}