locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# 1. Network: VPC, subnets, Internet Gateway, route tables
module "network" {
  source = "./modules/network"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}
