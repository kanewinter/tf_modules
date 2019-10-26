variable "vpc_id" {}
variable "tags" { type="map" }
variable "public_subnet_ids" {}
variable "private_subnet_ids" {}
variable "nat_gateway_ids" { type="list" }
variable "ig_id" {}