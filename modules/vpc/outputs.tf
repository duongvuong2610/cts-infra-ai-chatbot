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