variable "s3" {
  description = "Map of S3 bucket names and their configurations"

  type = map(object({
    acl                      = string
    control_object_ownership = bool
    object_ownership         = string
    versioning               = bool
  }))

  default = {
    "ctx-ai-chatbot-s3-source-data-187091248012" = {
      acl                      = "private"
      control_object_ownership = true
      object_ownership         = "ObjectWriter"
      versioning               = true
    },
    "ctx-ai-chatbot-s3-enriched-data-187091248012" = {
      acl                      = "private"
      control_object_ownership = true
      object_ownership         = "ObjectWriter"
      versioning               = true
    }
  }
}
