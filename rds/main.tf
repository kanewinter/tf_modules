#####
# DB Modifications to the database are applied during the maintenance window unless you set "apply_immediately"
#####
locals {
  rds_name = "${replace("${var.application}-rds-${var.environment}", "-", "")}"
  env = "${replace("${var.environment}", "-", "")}"
  username = "${replace("${var.application}_${var.environment}", "-", "")}"
}

module "rds" {
  #version = "1.20.0"
  source = "github.com/kanewinter/terraform-aws-rds"
  identifier = "${local.rds_name}"

  # All available versions: http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html#MySQL.Concepts.VersionMgmt
  engine            = "${var.rds_engine}"
  engine_version    = "${var.rds_engine_version}"
  instance_class    = "${var.rds_instance_class}"
  allocated_storage = "${var.rds_allocated_storage}"
  storage_encrypted = "${var.rds_storage_encrypted}"
  multi_az          = "${var.rds_multi_az}"
  
  # kms_key_id        = "arm:aws:kms:<region>:<accound id>:key/<kms key id>"
  name     = "${local.rds_name}"
  username = "${local.username}"
  password = "${var.rds_password}"
  port     = "${var.rds_port}"
  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]
  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # disable backups to create DB faster
  backup_retention_period = "${var.rds_retention}"

  tags = "${merge(map(
    "Name", "${var.application}-${var.environment}"),
    var.tags
  )}"

  # DB subnet group
  create_db_subnet_group = false
  db_subnet_group_name = "${var.subnet_group_id}"

  # DB parameter group
  family = "mysql5.7"

  # DB option group
  major_engine_version = "5.7"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "${var.application}db"

  create_db_parameter_group = false
  parameter_group_name = "${var.parameter_group_id}"

  create_db_option_group = false
  option_group_name = "${var.option_group_id}"
}