output "vpc_id" {
  description = "ID if the CloudDeploy VPC"
  value = aws_vpc.this.id
}

output "vpc_cidr_block" {
    description = "CIDR block of the CloudDeploy VPC"
    value = aws_vpc.this.cidr_block
}