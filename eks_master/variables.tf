variable "eks_name" {}

variable "eks_subnet_ids" { type = list(string) }

variable "tags" {
  type = "map"
}

variable "vpc_id" {}