variable "environment" {}
variable "azs" { type="list" }
variable "public_subnets_cidr" { type="list" }
variable "private_subnets_cidr" { type="list" }
variable "tags" { type="map" }
variable "vpc_id" {}