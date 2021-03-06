variable "azs" {
  type = list(string)
  description = "availability zones"
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
variable "vpc_cidr" {
  default = "10.10.0.0/16"
}
variable "tags" { type="map" }
variable "public_subnets_cidr" {
  type    = list(string)
  default = ["10.10.0.0/19", "10.10.32.0/19", "10.10.64.0/19"]
}
variable "private_subnets_cidr" {
  type    = list(string)
  default = ["10.10.128.0/19", "10.10.160.0/19", "10.10.192.0/19"]
}
