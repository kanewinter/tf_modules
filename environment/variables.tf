variable "tags" {
  type = map(string)
}

variable "public_subnets_cidr" {
  type    = list(string)
  default = []
}

variable "private_subnets_cidr" {
  type    = list(string)
  default = []
}

variable "eks_node_public_instance_type" {
  default = "t3.xlarge"
}

variable "eks_node_private_instance_type" {
  default = "t3.xlarge"
}

variable "eks_node_public_min_size" {
  default = "20"
}

variable "eks_node_public_max_size" {
  default = "40"
}

variable "eks_node_private_min_size" {
  default = "20"
}

variable "eks_node_private_max_size" {
  default = "40"
}

