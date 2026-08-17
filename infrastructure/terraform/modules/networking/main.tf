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
