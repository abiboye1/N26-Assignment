# Store SSH keys in Secrets Manager
resource "aws_secretsmanager_secret" "appserver_secret" {
  name = "appserver-secret2"
}

resource "aws_secretsmanager_secret_version" "appserver_secret_version" {
  secret_id = aws_secretsmanager_secret.appserver_secret.id
  secret_string = jsonencode({
    "n26-bastion" = {
      username     = "ec2-user",
      private_key  = tls_private_key.generated.private_key_pem
    },
    "n26-web-instance" = {
      username     = "ec2-user",
      private_key  = tls_private_key.generated.private_key_pem
    },
    "n26-app-instance" = {
      username     = "ec2-user",
      private_key  = tls_private_key.generated.private_key_pem
    }
  })
}

