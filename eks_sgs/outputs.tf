output "eks_node_public_sg_id" {
  value = "${aws_security_group.eks-node-public.id}"
}

output "eks_node_public_sg_arn" {
  value = "${aws_security_group.eks-node-public.arn}"
}

output "eks_node_private_sg_id" {
  value = "${aws_security_group.eks-node-private.id}"
}

output "eks_node_private_sg_arn" {
  value = "${aws_security_group.eks-node-private.arn}"
}

output "eks_node_environment_sg_id" {
  value = "${aws_security_group.eks-node-environment.id}"
}

output "eks_node_environment_sg_arn" {
  value = "${aws_security_group.eks-node-environment.arn}"
}