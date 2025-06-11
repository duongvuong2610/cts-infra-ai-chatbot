variable "dynamodb_table" {
  description = "Configuration for creating a dynamodb table"

  type = object({
    name     = string
    hash_key = string
    attributes = list(object({
      name = string
      type = string
    }))
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
  }
}
