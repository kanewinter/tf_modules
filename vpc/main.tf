resource "aws_vpc" "vpc" {
  cidr_block = "${var.cidr}"
  enable_dns_hostnames = "true"
  tags = "${var.tags}"
}

resource "aws_default_route_table" "default" {
  default_route_table_id = "${aws_vpc.vpc.default_route_table_id}"
/*  route {
    # ...
  }*/
  tags = {
    Name = "default table"
  }
}