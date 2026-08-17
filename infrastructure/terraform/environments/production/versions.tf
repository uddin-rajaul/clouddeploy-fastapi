terraform {
  required_version = "~> 1.15"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.60"
    }
  }

  backend "s3" {
    bucket       = "clouddeploy-terraform-state-116527261682"
    key          = "clouddeploy/production/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true

  }
}