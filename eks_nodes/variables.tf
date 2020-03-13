variable "tags" {
  type = "map"
}

variable "eks_node_instance_profile" {}

variable "eks_node_public_instance_type" {}

variable "eks_node_private_instance_type" {}

variable "eks_node_public_max_size" {}

variable "eks_node_private_max_size" {}

variable "eks_node_public_min_size" {}

variable "eks_node_private_min_size" {}

variable "eks_node_public_sg_id" {}

variable "eks_node_private_sg_id" {}

variable "eks_node_environment_sg_id" {}

variable "public_eks_subnet_ids" { type = list(string) }

variable "private_eks_subnet_ids" { type = list(string) }