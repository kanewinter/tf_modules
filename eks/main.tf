data "aws_vpc" "vpc" {
  id = "${var.vpc_id}"
}

locals {
  cidr = "${data.aws_vpc.vpc.cidr_block}"
}

module "eks_master" {
  source = "../eks_master"
  eks_subnet_ids = var.eks_subnet_ids
  vpc_id = "${var.vpc_id}"
  eks_name = "eks_${var.tags["environment"]}"
  tags = "${var.tags}"
}

module "eks_sgs" {
  source = "../eks_sgs"
  cidr = local.cidr
  env = "${var.tags["environment"]}"
  eks_name = "eks_${var.tags["environment"]}"
  eks_sg_id = "${module.eks_master.eks_sg_id}"
  vpc_id = "${var.vpc_id}"
}

module "eks_nodes" {
  source = "../eks_nodes"
  public_eks_subnet_ids = "${var.public_eks_subnet_ids}"
  private_eks_subnet_ids = "${var.private_eks_subnet_ids}"
  eks_node_instance_profile = "${module.eks_master.eks_node_instance_profile}"
  eks_node_public_instance_type = "${var.eks_node_public_instance_type}"
  eks_node_private_instance_type = "${var.eks_node_private_instance_type}"
  eks_node_public_min_size = "${var.eks_node_public_min_size}"
  eks_node_public_max_size = "${var.eks_node_public_max_size}"
  eks_node_private_min_size = "${var.eks_node_private_min_size}"
  eks_node_private_max_size = "${var.eks_node_private_max_size}"
  eks_node_public_sg_id = "${module.eks_sgs.eks_node_public_sg_id}"
  eks_node_private_sg_id = "${module.eks_sgs.eks_node_private_sg_id}"
  eks_node_environment_sg_id = "${module.eks_sgs.eks_node_environment_sg_id}"
  tags = "${var.tags}"
}