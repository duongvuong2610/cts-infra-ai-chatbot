variable "ecs_cluster" {
  description = "Configuration of ECS cluster"
  type = object({
    name = string
  })
}