output "eks_node_private_sg_id" {
  value = "${module.eks_sgs.eks_node_private_sg_id}"
}

output "kubeconfig" {
  value = "${module.eks_master.kubeconfig}"
}

output "config-map-aws-auth" {
  value = "${module.eks_master.config-map-aws-auth}"
}