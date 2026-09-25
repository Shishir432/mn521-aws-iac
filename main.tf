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

# 3. Compute: SSH key pair, bastion host and private Linux server
module "compute" {
  source = "./modules/compute"

  name_prefix       = local.name_prefix
  instance_type     = var.instance_type
  public_subnet_id  = module.network.public_subnet_ids["a"]
  private_subnet_id = module.network.private_subnet_ids["a"]
  bastion_sg_id     = module.security.bastion_sg_id
  private_sg_id     = module.security.private_sg_id
  key_output_dir    = "${path.root}/keys"
}
