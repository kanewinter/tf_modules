output "nat_ids" {
  value = "${aws_nat_gateway.nat_gateway_per_subnet.*.id}"
}