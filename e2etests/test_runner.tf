resource "local_file" "e2e_tests" {
  sensitive_content = <<EOF
#!/bin/bash -eo pipefail

%{for k, v in local.tests}
echo "Running test ${k}"
aws transfer test-identity-provider --server-id ${aws_transfer_server.sftp.id} --user-name ${v.UserId} --user-password ${random_password.password[k].result} --region eu-west-1
%{endfor}
EOF
  filename          = "/tmp/e2e-tests.sh"
}