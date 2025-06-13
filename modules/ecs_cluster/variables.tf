variable "vpc_zone_identifier" {
  type = list(string) # public subnet
}

variable "vpc_id" {
  type = string
}

variable "task_role_arn" {
  type = string
}