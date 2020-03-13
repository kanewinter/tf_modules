output "eks_node_instance_profile" {
  value = "${aws_iam_instance_profile.eks-nodes.name}"
}

output "config-map-aws-auth" {
  value = "${local.config-map-aws-auth}"
}

output "kubeconfig" {
  value = "${local.kubeconfig}"
}

output "eks_sg_id" {
  value = "${aws_security_group.eks.id}"
}

output "eks_node_sg_id" {
  value = "${aws_security_group.eks-node-global.id}"
}

/*output "eks_user_id" {
  sensitive = true
  value = "${aws_iam_access_key.eks.id}"
}

output "eks_user_secret" {
  sensitive = true
  value = "${aws_iam_access_key.eks.secret}"
}*/