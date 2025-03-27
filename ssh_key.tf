resource "tls_private_key" "generated" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated" {
  key_name   = "n26-generated-key"
  public_key = tls_private_key.generated.public_key_openssh
}
