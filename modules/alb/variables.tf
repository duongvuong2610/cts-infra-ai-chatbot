variable "alb" {
  description = "Configuration for the ALB module"

  type = object({
    name = string
    vpc_id = string
    subnets = list(string)
    security_groups = list(string)
    enable_deletion_protection = optional(bool, false)
  })
}
