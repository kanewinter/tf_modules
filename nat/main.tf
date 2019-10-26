resource "aws_nat_gateway" "nat_gateway_per_subnet" {
  count = "${length(var.subnet_ids)}"
  allocation_id = "${aws_eip.nat_ip.*.id[count.index]}"
  subnet_id = "${var.subnet_ids[count.index]}"
  tags = "${var.tags}"
}

resource "aws_eip" "nat_ip" {
  count = "${length(var.subnet_ids)}"
  vpc = true
  tags = "${var.tags}"
}