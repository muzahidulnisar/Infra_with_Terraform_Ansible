# AWS Region
variable "aws_region" {
  default = "ap-south-1"
}

# AWS Availability Zone 1
variable "aws_az1" {
  default = "ap-south-1a"
}

# AWS Availability Zone 2
variable "aws_az2" {
  default = "ap-south-1b"
}

# VPC CIDR block
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

# Public subnet CIDR block
variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}

# Private subnet CIDR block
variable "private_subnet_cidr" {
  default = "10.0.2.0/24"
}

# Any IPv4 CIDR block
variable "any_ipv4_cidr" {
  default = "0.0.0.0/0"
}

# AMI ID for EC2 Ubuntu 22.04 instance
variable "ami_id_ubuntu" {
  default = "ami-09b0a86a2c84101e1"
}

# Micro EC2 instance type
variable "micro_instance_type" {
  default = "t2.micro"
}

# Tags for resources
variable "tags" {
  type = map(string)
  default = {
    vpc                 = "terraform-vpc"
    public_subnet       = "terraform-public-subnet"
    private_subnet      = "terraform-private-subnet"
    internet_gateway    = "terraform-igw"
    nat_gateway         = "terraform-nat-gw"
    public_route_table  = "terraform-public-rtb"
    private_route_table = "terraform-private-rtb"
    web_server          = "WebServer"
    web_server_sg       = "web_server_sg"
    db_server           = "DBServer"
    db_server_sg        = "db_server_sg"
  }
}