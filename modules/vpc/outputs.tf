output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "IDs of the created private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "IDs of the created public subnets"
  value       = module.vpc.public_subnets
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value = module.vpc.private_route_table_ids
}

output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value = module.vpc.public_route_table_ids
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value = module.vpc.vpc_cidr_block
}