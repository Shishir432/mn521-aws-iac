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

# 2. Security: least-privilege security groups
module "security" {
  source = "./modules/security"

  name_prefix = local.name_prefix
  vpc_id      = module.network.vpc_id
  vpc_cidr    = module.network.vpc_cidr
  admin_cidr  = var.admin_cidr
}
