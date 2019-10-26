locals {
  nat_number = "${length(var.nat_gateway_ids)}"
}

resource "aws_route_table" "private" {
  vpc_id = "${var.vpc_id}"
  tags = "${var.tags}"
}

resource "aws_route_table" "public" {
  vpc_id = "${var.vpc_id}"
  tags = "${var.tags}"
}

resource "aws_route" "private_nat_gateway" {
  #count = "${local.nat_number}"
  #count = length(var.nat_gateway_ids)
  route_table_id = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  depends_on = ["aws_route_table.private"]
  nat_gateway_id = var.nat_gateway_ids[0]
}

resource "aws_route" "public_gateway" {
  route_table_id = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  depends_on = ["aws_route_table.public"]
  gateway_id = "${var.ig_id}"
}

resource "aws_route_table_association" "private_associations" {
  count = "${length(var.private_subnet_ids)}"
  subnet_id      = "${var.private_subnet_ids[count.index]}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "public_associations" {
  count = "${length(var.public_subnet_ids)}"
  subnet_id      = "${var.public_subnet_ids[count.index]}"
  route_table_id = "${aws_route_table.public.id}"
}