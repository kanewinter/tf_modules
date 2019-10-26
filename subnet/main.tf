locals {
  public_subnet_tags = "${merge(map(
    "Name", "${var.environment}",
    "kubernetes.io/role/elb", "1",
    "kubernetes.io/cluster/eks-${var.environment}", "shared"),
    var.tags
  )}"
  private_subnet_tags = "${merge(map(
    "Name", "${var.environment}",
    "kubernetes.io/role/internal-elb", "1",
    "kubernetes.io/cluster/eks-${var.environment}", "shared"),
    var.tags
  )}"
}

resource "aws_subnet" "public_subnet" {
  count             = "${length(var.public_subnets_cidr)}"
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${var.public_subnets_cidr[count.index]}"
  availability_zone = "${var.azs[count.index]}"
  tags = "${local.public_subnet_tags}"
}
resource "aws_subnet" "private_subnet" {
  count             = "${length(var.private_subnets_cidr)}"
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${var.private_subnets_cidr[count.index]}"
  availability_zone = "${var.azs[count.index]}"
  tags = "${local.private_subnet_tags}"
}