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
}
