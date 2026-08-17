resource "aws_vpc" "this" {
    cidr_block = var.cidr_block
    instance_tenancy = "default"
    enable_dns_support = var.enable_dns_support
    enable_dns_hostnames = var.enable_dns_hostnames

    tags = {
        Name = var.name
    }
}

resource "aws_subnet" "public_1a" {
  vpc_id = aws_vpc.this.id
  cidr_block = var.public_subnet_cidr_block
  availability_zone = var.public_subnet_availability_zone
  map_public_ip_on_launch = var.public_subnet_map_public_ip_on_launch

  tags = {
    Name = var.public_subnet_name
  }
}

resource "aws_subnet" "private_1a" {
  vpc_id = aws_vpc.this.id
  cidr_block = var.private_1a_cidr_block
  availability_zone = var.private_1a_availability_zone
  tags = {
    Name = var.private_1a_name
  }
}

resource "aws_subnet" "private_1b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_1b_cidr_block
  availability_zone = var.private_1b_availability_zone

  tags = {
    Name = var.private_1b_name
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = var.internet_gateway_name
  }
}