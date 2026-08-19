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
  private_1a_cidr_block                 = "10.0.2.0/24"
  private_1a_availability_zone          = "ap-south-1a"
  private_1a_name                       = "clouddeploy-private-subnet-1a"
  private_1b_cidr_block                 = "10.0.3.0/24"
  private_1b_availability_zone          = "ap-south-1b"
  private_1b_name                       = "clouddeploy-private-subnet-1b"
  internet_gateway_name                 = "clouddeploy-igw"
  public_route_table_name               = "clouddeploy-public-rt"
}

module "security" {
  source                = "../../modules/security"
  vpc_id                = module.networking.vpc_id
  web_security_group_id = "sg-0f587876d8e314354"
}

module "database" {
  source = "../../modules/database"
  subnet_ids = [
    module.networking.private_subnet_1a_id,
    module.networking.private_subnet_1b_id
  ]
  rds_security_group_id = module.security.rds_security_group_id
}

module "iam" {
  source = "../../modules/iam"
}

module "compute" {
  source = "../../modules/compute"

  ami_id               = "ami-035827357e3c7e810"
  instance_type        = "t3.micro"
  subnet_id            = module.networking.public_1a_id
  private_ip           = "10.0.1.82"
  security_group_ids   = ["sg-0f587876d8e314354"]
  key_name             = "clouddeploy-key"
  iam_instance_profile = module.iam.instance_profile_name
}