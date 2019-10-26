output "subnet_group_id" {
  value = "${aws_db_subnet_group.default.id}"
}

output "parameter_group_id" {
  value = "${aws_db_parameter_group.default.id}"
}

output "option_group_id" {
  value = "${aws_db_option_group.default.id}"
}