output "invoke_url" {
    value = "${aws_api_gateway_stage.prod.invoke_url}"
}

output "rest_api_id" {
    value = "${aws_api_gateway_rest_api.sftp-idp-secrets.id}"
}

