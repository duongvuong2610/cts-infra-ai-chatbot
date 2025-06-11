output "repository_arn" {
  description = "Full ARN of the repository"
  value = module.ecr.repository_arn
}

output "repository_name" {
  description = "Name of the repository"
  value = module.ecr.repository_name
}