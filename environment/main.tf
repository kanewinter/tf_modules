module "network" {
  source = "../network"
  tags   = var.tags
}

module "securitygroups" {
  source = "../securitygroups"
  vpc_id = module.network.vpc_id
}

module "eks" {
  source                         = "../eks"
  vpc_id                         = module.network.vpc_id
  eks_subnet_ids                 = module.network.all_subnet_ids
  public_eks_subnet_ids          = module.network.public_subnet_ids
  private_eks_subnet_ids         = module.network.private_subnet_ids
  eks_node_public_instance_type  = var.eks_node_public_instance_type
  eks_node_private_instance_type = var.eks_node_private_instance_type
  eks_node_public_min_size       = var.eks_node_public_min_size
  eks_node_public_max_size       = var.eks_node_public_max_size
  eks_node_private_min_size      = var.eks_node_private_min_size
  eks_node_private_max_size      = var.eks_node_private_max_size
  tags                           = var.tags
}

module "rds_defaults" {
  source     = "../rds/defaults"
  subnet_ids = module.network.private_subnet_ids
  tags       = var.tags
}

resource "aws_elasticache_subnet_group" "default" {
  name        = "default-${var.tags["environment"]}"
  description = "Subnets the Redis instances can be place into."
  subnet_ids  = module.network.private_subnet_ids
}

