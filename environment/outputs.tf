output "eks_node_private_sg_id" {
  value = module.eks.eks_node_private_sg_id
  sensitive = "true"
}

output "kubeconfig" {
  value = module.eks.kubeconfig
  sensitive = "true"
}

output "config-map-aws-auth" {
  value = module.eks.config-map-aws-auth
  sensitive = "true"
}

