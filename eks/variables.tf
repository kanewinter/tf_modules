variable "eks_subnet_ids" {
  type    = list(string)
}
variable "private_eks_subnet_ids" {
  type    = list(string)
}
variable "public_eks_subnet_ids" {
  type    = list(string)
}
variable "vpc_id" {}
variable "tags" {
  type = map(string)
}
variable "eks_node_public_instance_type" {}
variable "eks_node_private_instance_type" {}
variable "eks_node_public_min_size" {}
variable "eks_node_public_max_size" {}
variable "eks_node_private_min_size" {}
variable "eks_node_private_max_size" {}