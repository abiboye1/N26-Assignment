resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "n26-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "n26-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block             = var.public_subnet_cidrs[count.index]
  availability_zone       = "${var.aws_region}${element(["a","c"], count.index)}"
  map_public_ip_on_launch = true

  tags = {
    Name = "n26-public-subnet-${count.index}"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "n26-public-rt"
  }
}

resource "aws_route_table_association" "public_rta" {
  count = length(var.public_subnet_cidrs)

  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# NAT Gateway (for private subnets to access the internet)
resource "aws_eip" "nat_eip" {
  depends_on = [aws_internet_gateway.igw]
  vpc        = true
  tags = {
    Name = "n26-nat-eip"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id
  # For cost reasons, we only create 1 NAT in the first public subnet
  tags = {
    Name = "n26-nat-gw"
  }
}

# Private App Subnets
resource "aws_subnet" "private_app_subnets" {
  count             = length(var.private_app_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_app_subnet_cidrs[count.index]
  availability_zone = "${var.aws_region}${element(["a","c"], count.index)}"

  tags = {
    Name = "n26-private-app-subnet-${count.index}"
  }
}

resource "aws_route_table" "private_app_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "n26-private-app-rt"
  }
}

resource "aws_route_table_association" "private_app_rta" {
  count = length(var.private_app_subnet_cidrs)

  subnet_id      = aws_subnet.private_app_subnets[count.index].id
  route_table_id = aws_route_table.private_app_rt.id
}

# Private DB Subnets (No NAT route - they typically don't need direct internet)
resource "aws_subnet" "private_db_subnets" {
  count             = length(var.private_db_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_db_subnet_cidrs[count.index]
  availability_zone = "${var.aws_region}${element(["a","c"], count.index)}"

  tags = {
    Name = "n26-private-db-subnet-${count.index}"
  }
}
