variable "ecr" {
  description = "Configuration for creating the ECR"

  type = object({
    repository_name                   = string
    repository_read_write_access_arns = list(string)
    repository_lifecycle_policy = object({
      rules = list(object({
        rulePriority = number,
        description  = string,
        selection = object({
          tagStatus     = string,
          tagPrefixList = list(string),
          countType     = string,
          countNumber   = number
        }),
        action = object({
          type = string
        })
      }))
    })
  })
}
