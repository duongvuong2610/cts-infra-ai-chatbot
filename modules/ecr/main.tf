module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name                   = var.ecr.repository_name
  repository_read_write_access_arns = var.repository_read_write_access_arns
  repository_lifecycle_policy       = jsonencode(var.ecr.repository_lifecycle_policy)
}
