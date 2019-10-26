locals {
  environment = var.tags["environment"]
  env = replace(local.environment, "-", "_")
}

resource "aws_db_option_group" "default" {
  name_prefix              = "default-${local.environment}-"
  option_group_description = "default-${local.env}"
  engine_name              = "mysql"
  major_engine_version     = "5.7"
  option {
    option_name = "MARIADB_AUDIT_PLUGIN"

    option_settings {
        name  = "SERVER_AUDIT_EVENTS"
        value = "CONNECT"
      }
    option_settings {
        name  = "SERVER_AUDIT_FILE_ROTATIONS"
        value = "37"
      }
    }
  tags = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_parameter_group" "default" {
  name_prefix = "default-${local.environment}-"
  description = "default-${local.env}"
  family      = "mysql5.7"
  parameter {
    name = "log_bin_trust_function_creators"
    value = 1
  }
  tags = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_subnet_group" "default" {
  name_prefix = "default_${local.env}-"
  subnet_ids = var.subnet_ids
  tags = var.tags
}