variable "tags" {
  type = "map"
}

variable "security_group_id" {
  default = ""
}

variable "subnet_ids" {
  type = "list"
}

variable "cloudwatch_log_group" {
  default = ""
}

variable "instance_type" {
  default = "t2.small.elasticsearch"
}