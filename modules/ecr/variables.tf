variable "ecr" {
  description = "Configuration for creating the ECR"

  type = object({
    repository_name = string
    repository_read_write_access_arns = list(string)
  })

  default = {
    repository_name = "ctx-ai-chatbot-ecr"
    repository_read_write_access_arns = [ "arn:aws:iam::012345678901:role/terraform" ]
  }
}