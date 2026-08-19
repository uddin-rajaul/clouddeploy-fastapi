output "vpc_id" {
  description = "ID if the CloudDeploy VPC"
  value = aws_vpc.this.id
}

output "vpc_cidr_block" {
    description = "CIDR block of the CloudDeploy VPC"
    value = aws_vpc.this.cidr_block
}

output "private_subnet_1a_id" {
  description = "ID of the private subnet in ap-south-1a"
  value       = aws_subnet.private_1a.id
}

output "private_subnet_1b_id" {
  description = "ID of the private subnet in ap-south-1b"
  value       = aws_subnet.private_1b.id
}