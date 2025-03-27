resource "aws_db_subnet_group" "db_subnet_group" {
  name = "n26-db-subnet-group"
  subnet_ids = [
    aws_subnet.private_db_subnets[0].id,
    aws_subnet.private_db_subnets[1].id
  ]

  tags = {
    Name = "n26-db-subnet-group"
  }
}

resource "aws_db_instance" "n26_db" {
  identifier              = "n26-db"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_encrypted       = true
  kms_key_id              = data.aws_kms_key.rds.arn
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  username                = var.db_username
  password                = var.db_password
  skip_final_snapshot     = true

  tags = {
    Name = "n26-rds"
  }
}
