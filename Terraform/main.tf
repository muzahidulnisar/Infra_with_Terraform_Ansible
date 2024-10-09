# Provider configuration
provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.tags["vpc"]
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr
  availability_zone       = var.aws_az1
  map_public_ip_on_launch = true

  tags = {
    Name = var.tags["public_subnet"]
  }
}

# Private Subnet
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr
  availability_zone       = var.aws_az2

  tags = {
    Name = var.tags["private_subnet"]
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.tags["internet_gateway"]
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = var.tags["nat_gateway"]
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.any_ipv4_cidr
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.tags["public_route_table"]
  }
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.any_ipv4_cidr
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = var.tags["private_route_table"]
  }
}

resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
}

# Create a key
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key_pair" {
  key_name   = "terraform-generated-key"
  public_key = tls_private_key.example.public_key_openssh
}

# Save the private key locally
resource "local_file" "private_key" {
  content  = tls_private_key.example.private_key_pem
  filename = "${path.module}/terraform-generated-key.pem"
}

# Ubuntu EC2 instance for Web Server
resource "aws_instance" "web_server" {
  ami           = var.ami_id_ubuntu
  instance_type = var.micro_instance_type
  subnet_id     = aws_subnet.public.id
  security_groups = [aws_security_group.web_sg.id]
  key_name      = "terraform-generated-key"

  tags = {
    Name = var.tags["web_server"]
  }
}

# Ubuntu EC2 instance for DB Server
resource "aws_instance" "db_server" {
  ami           = var.ami_id_ubuntu
  instance_type = var.micro_instance_type
  subnet_id     = aws_subnet.private.id
  security_groups = [aws_security_group.db_sg.id]
  key_name      = "terraform-generated-key"

  tags = {
    Name = var.tags["db_server"]
  }
}

# Security group for Web Server
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.any_ipv4_cidr]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.any_ipv4_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.any_ipv4_cidr]
  }

  tags = {
    Name = var.tags["web_server_sg"]
  }
}

# Security group for DB Server
resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.any_ipv4_cidr]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.any_ipv4_cidr]
  }

  tags = {
    Name = var.tags["db_server_sg"]
  }
}

