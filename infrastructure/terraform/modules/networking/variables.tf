variable "name" {
    description = "Name tag for the vpc"
    type = string
}

variable "cidr_block" {
    description = "IPv4 block for the VPC"
    type = string
}

variable "enable_dns_support" {
    description = "Whether DNS resolution is enabled in the VPC"
    type = bool
}

variable "enable_dns_hostnames" {
  description = "Whether DNS hostnames are enabled in the VPC"
  type = bool
}

variable "public_subnet_cidr_block" {
  description = "IPv4 CIDR block for the public subnet"
  type = string
}

variable "public_subnet_availability_zone" {
  description = "Availability zone for the public subnet"
  type = string
}

variable "public_subnet_map_public_ip_on_launch" {
  description = "Whether instances launched in the subnet receive the publiv IPv4 addreesses"
  type = bool
}

variable "public_subnet_name" {
  description = "Name tag for the public subnet"
  type = string
}

variable "private_1a_cidr_block" {
  description = "IPv4 CIDR block for the private subnet in ap-south-1a"
  type  = string
}

variable "private_1a_availability_zone" {
    description = "Availability Zone for the Private Subnet in ap-south-1a"
    type = string   
}

variable "private_1a_name" {
  description = "Name tag for the private subnet in ap-south-1a"
  type = string
}

variable "private_1b_cidr_block" {
  description = "IPv4 CIDR block for the private subnet in ap-south-1b"
  type        = string
}

variable "private_1b_availability_zone" {
  description = "Availability Zone for the private subnet in ap-south-1b"
  type        = string
}

variable "private_1b_name" {
  description = "Name tag for the private subnet in ap-south-1b"
  type        = string
}