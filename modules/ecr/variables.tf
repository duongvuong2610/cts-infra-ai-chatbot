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
    tags = object({
      Owner     = string
      Terraform = string
    })
  })

  default = {
    repository_name                   = "ctx-ai-chatbot-ecr"
    repository_read_write_access_arns = ["arn:aws:iam::012345678901:role/terraform"]
    repository_lifecycle_policy = {
      rules = [
        {
          rulePriority = 1,
          description  = "Keep last 30 images",
          selection = {
            tagStatus     = "tagged",
            tagPrefixList = ["v"],
            countType     = "imageCountMoreThan",
            countNumber   = 30
          },
          action = {
            type = "expire"
          }
        }
      ]
    }
    tags = {
      Owner     = "CTX"
      Terraform = "true"
    }
  }
}
