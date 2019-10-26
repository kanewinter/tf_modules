resource "aws_internet_gateway" "public_gateway" {
  vpc_id = "${var.vpc_id}"
  tags = "${var.tags}"
}

