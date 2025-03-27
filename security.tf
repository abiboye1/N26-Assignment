###############################################################################
# NACLs
###############################################################################
# Public NACL for public subnets
resource "aws_network_acl" "public_nacl" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "n26-public-nacl"
  }
}

# inbound/outbound for HTTP/HTTPS, ephemeral, etc.
resource "aws_network_acl_rule" "public_nacl_inbound_http" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
  rule_action    = "allow"
}

resource "aws_network_acl_rule" "public_nacl_inbound_https" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
  rule_action    = "allow"
}

resource "aws_network_acl_rule" "public_nacl_inbound_ephemeral" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 120
  egress         = false
  protocol       = "tcp"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
  rule_action    = "allow"
}

resource "aws_network_acl_rule" "public_nacl_outbound_all" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 130
  egress         = true
  protocol       = "-1"
  cidr_block     = "0.0.0.0/0"
  rule_action    = "allow"
}

resource "aws_network_acl_association" "public_nacl_assoc" {
  count         = length(var.public_subnet_cidrs)
  subnet_id     = aws_subnet.public_subnets[count.index].id
  network_acl_id = aws_network_acl.public_nacl.id
}

# Private NACL for app subnets
resource "aws_network_acl" "app_nacl" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "n26-app-nacl"
  }
}

resource "aws_network_acl_rule" "app_nacl_inbound_http" {
  network_acl_id = aws_network_acl.app_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  cidr_block     = "10.0.0.0/16"
  from_port      = 80
  to_port        = 80
  rule_action    = "allow"
}

resource "aws_network_acl_rule" "app_nacl_inbound_ephemeral" {
  network_acl_id = aws_network_acl.app_nacl.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  cidr_block     = "10.0.0.0/16"
  from_port      = 1024
  to_port        = 65535
  rule_action    = "allow"
}

resource "aws_network_acl_rule" "app_nacl_outbound_all" {
  network_acl_id = aws_network_acl.app_nacl.id
  rule_number    = 120
  egress         = true
  protocol       = "-1"
  cidr_block     = "0.0.0.0/0"
  rule_action    = "allow"
}

resource "aws_network_acl_association" "app_nacl_assoc" {
  count         = length(var.private_app_subnet_cidrs)
  subnet_id     = aws_subnet.private_app_subnets[count.index].id
  network_acl_id = aws_network_acl.app_nacl.id
}

# DB NACL for DB subnets
resource "aws_network_acl" "db_nacl" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "n26-db-nacl"
  }
}

resource "aws_network_acl_rule" "db_nacl_inbound_mysql" {
  network_acl_id = aws_network_acl.db_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  cidr_block     = "10.0.0.0/16"
  from_port      = 3306
  to_port        = 3306
  rule_action    = "allow"
}

resource "aws_network_acl_rule" "db_nacl_inbound_ephemeral" {
  network_acl_id = aws_network_acl.db_nacl.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  cidr_block     = "10.0.0.0/16"
  from_port      = 1024
  to_port        = 65535
  rule_action    = "allow"
}

resource "aws_network_acl_rule" "db_nacl_outbound_all" {
  network_acl_id = aws_network_acl.db_nacl.id
  rule_number    = 120
  egress         = true
  protocol       = "-1"
  cidr_block     = "0.0.0.0/0"
  rule_action    = "allow"
}

resource "aws_network_acl_association" "db_nacl_assoc" {
  count         = length(var.private_db_subnet_cidrs)
  subnet_id     = aws_subnet.private_db_subnets[count.index].id
  network_acl_id = aws_network_acl.db_nacl.id
}

###############################################################################
# Security Groups
###############################################################################
# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security Group for the ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "n26-alb-sg"
  }
}

# Web Security Group
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Security Group for Web instances"
  vpc_id      = aws_vpc.main.id

  # ALB -> web servers
  ingress {
    description      = "HTTP from ALB"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "n26-web-sg"
  }
}

# App Security Group
resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Security Group for App instances"
  vpc_id      = aws_vpc.main.id

  # In a real scenario, the app might accept traffic from the web tier or not
  # For demonstration, let's assume it only needs inbound from web tier
  # on some custom port (like 8080) or none at all
  # (We'll keep it minimal for now.)

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "n26-app-sg"
  }
}

# DB Security Group
resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Security Group for Database Tier"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from App SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "n26-db-sg"
  }
}

# Bastion Security Group
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Security Group for Bastion"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.bastion_allowed_ip]
  }



  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "n26-bastion-sg"
  }
}
