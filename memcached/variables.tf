variable "tags" {
  type = "map"
}
variable "parameter_group_name" {}
variable "azs" {
  type = "list"
}
variable "az_mode" {
  default = "cross-az"
}
variable "node_type" {
  default = "cache.t2.micro"
}
variable "engine" {
  default = "memcached"
}