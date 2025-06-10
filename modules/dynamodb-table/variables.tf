variable "dynamodb_table" {
  description = "Configuration for creating a dynamodb table"

  type = object({
    name     = string
    hash_key = string
    attributes = list(object({
      name = string
      type = string
    }))
    tags = object({
      Owner     = string
      Terraform = string
    })
  })

  default = {
    name     = "ai-chatbot-session-chat"
    hash_key = "id"
    attributes = [
      {
        name = "id"
        type = "N"
      }
    ]
    tags = {
      Owner     = "CTX"
      Terraform = "true"
    }
  }
}
