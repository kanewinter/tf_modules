output "endpoint" {
  value = "${module.rds.this_db_instance_endpoint}"
}

output "name" {
  value = "${module.rds.this_db_instance_name}"
}

output "username" {
  value = "${local.username}"
}