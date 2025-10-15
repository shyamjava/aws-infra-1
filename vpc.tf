# VPC Module
module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  aws_region          = var.aws_region
}
