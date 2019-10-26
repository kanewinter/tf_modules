variable "region" {
  type = "string"
  description = "The AWS region to deploy into (e.g. us-east-1)"
}

variable "environment" {
  type = "string"
  description = "Context these resources will be used in, e.g. production"
}

variable "engine_version" {
  type = "string"
  description = "The version of Redis to use, e.g. 3.2.10.  If left blank, the latest engine is used."
  default = "5.0.3"
}

variable "maintenance_window" {
  type = "string"
  description = "The window to perform maintenance in."
  default = "Sun:03:00-Sun:05:00"
}

variable "node_type" {
  type = "string"
  description = "The instance type of the Redis instance, e.g. cache.t2.micro"
  default = "cache.t2.micro"
}

variable "parameter_group_name" {
  type = "string"
  description = "Name of the Redis parameter group to associate to the instance, e.g. default.redis3.2"
}

variable "security_group_ids" {
  type = "list"
  description = "List of VPC security groups to associate to the instance."
}

variable "apply_immediately" {
  type = "string"
  description = "If true, engine upgrades are done immediately, otherwise done during the next maintenance window."
  default = "true"
}

variable "snapshot_window" {
  type = "string"
  description = "The daily time range (in UTC) during which automated backups are created, if enabled."
  default = ""
}

variable "snapshot_retention_limit" {
  type = "string"
  description = "How many days to retain backups."
  default = "0"
}

variable "domain_name" {
  type = "string"
  description = "Route53 managed domain name to map the instance to, e.g. example.com."
  default = ""
}

variable "tags" {
  type = "map"
}

variable "azs" {
  type = "list"
}

variable "subnet_group" {}

variable "replica_count" {
  default = "1"
}