output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.subnets.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.subnets.private_subnet_ids
}

output "all_subnet_ids" {
  value = module.subnets.all_subnet_ids
}

output "public_subnet_cidr" {
  value = var.public_subnets_cidr
}

output "private_subnet_cidr" {
  value = var.private_subnets_cidr
}