provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      CreatedBy = "Terraform"
      Purpose   = "POC"
    }
  }
}

# module "local_vpc_module" {
#   source = "./modules/vpc"

#   vpc_cidr_block = "10.2.0.0/16"
#   pub_1_cidr     = "10.2.0.0/24"
#   pub_2_cidr     = "10.2.1.0/24"
#   priv_1_cidr    = "10.2.16.0/20"
#   priv_2_cidr    = "10.2.32.0/20"

# }

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}