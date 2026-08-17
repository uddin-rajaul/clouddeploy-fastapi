provider "aws" {
  region = "ap-south-1"
}

module "networking" {
  source                                = "../../modules/networking"
  name                                  = "clouddeploy-vpc"
  cidr_block                            = "10.0.0.0/16"
  enable_dns_support                    = true
  enable_dns_hostnames                  = true
  public_subnet_cidr_block              = "10.0.1.0/24"
  public_subnet_availability_zone       = "ap-south-1a"
  public_subnet_map_public_ip_on_launch = true
  public_subnet_name                    = "clouddeploy-public-subnet-1a"
}

