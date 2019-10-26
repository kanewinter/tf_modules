module "vpc" {
  source = "../vpc"
  cidr = "${var.vpc_cidr}"
  tags = "${var.tags}"
}

module "subnets" {
  source = "../subnet"
  environment = "${var.tags["environment"]}"
  azs = var.azs
  public_subnets_cidr = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  tags = "${var.tags}"
  vpc_id = "${module.vpc.vpc_id}"
}

module "gateways" {
  source = "../gateway"
  tags = "${var.tags}"
  vpc_id = "${module.vpc.vpc_id}"
}

module "nat" {
  source = "../nat"
  tags = "${var.tags}"
  subnet_ids = module.subnets.public_subnet_ids
}

module "route_tables" {
  source = "../route"
  vpc_id = "${module.vpc.vpc_id}"
  tags = "${var.tags}"
  public_subnet_ids = "${module.subnets.public_subnet_ids}"
  private_subnet_ids = "${module.subnets.private_subnet_ids}"
  nat_gateway_ids = "${module.nat.nat_ids}"
  ig_id = "${module.gateways.ig_id}"
}
