module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = var.alb.name
  vpc_id  = var.alb.vpc_id
  subnets = var.alb.subnets
  security_groups = var.alb.security_groups
  enable_deletion_protection = var.alb.enable_deletion_protection
}