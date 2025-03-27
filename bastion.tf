resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amzn2_linux.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_subnets[0].id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  associate_public_ip_address = true

  key_name = aws_key_pair.generated.key_name

  tags = {
    Name = "n26-bastion"
  }
}
