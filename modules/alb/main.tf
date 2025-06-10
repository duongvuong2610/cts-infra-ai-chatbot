module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = var.alb.name
  vpc_id  = var.vpc_id
  subnets = var.subnets
  security_groups = var.security_group_ids

  # Listeners and target groups from config
  listeners    = var.alb.listeners
  target_groups = var.alb.target_groups
  enable_deletion_protection = var.alb.enable_deletion_protection
}