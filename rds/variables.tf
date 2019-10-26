variable "application" {}

variable "rds_engine_version" {
  default = "5.7.22"
}

variable "rds_instance_class" {
  default = "db.t2.medium"
}

variable "rds_allocated_storage" {
  description = "rds_allocated_storage"
  default = 5
}

variable "rds_engine" {
  description = "rds_engine"
  default = "mysql"
}

variable "rds_storage_encrypted" {
  description = "storage_encrypted"
  default = false
}

variable "rds_password" {
  description = "rds_password"
}

variable "rds_retention" {
  default = 7
}

variable "rds_multi_az" {
  description = "multi_az"
  default = true
}

variable "rds_port" {
  default = 3306
}

variable "tags" {
  type = "map"
}

variable "environment" {}

variable "vpc_security_group_ids" {
  type = "list"
}

variable "subnet_group_id" {}

variable "parameter_group_id" {}

variable "option_group_id" {}