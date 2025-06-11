variable "s3_source_crawl" {
  description = "S3 bucket names and their configurations"

  type = object({
    bucket                   = string
    acl                      = string
    control_object_ownership = bool
    object_ownership         = string
    versioning               = bool
  })

  default = {
    bucket                   = "ctx-ai-chatbot-s3-source-crawl-187091248012"
    acl                      = "private"
    control_object_ownership = true
    object_ownership         = "ObjectWriter"
    versioning               = true
  }
}

variable "s3_vector_search" {
  description = "S3 bucket names and their configurations"

  type = object({
    bucket                   = string
    acl                      = string
    control_object_ownership = bool
    object_ownership         = string
    versioning               = bool
  })

  default = {
    bucket                   = "ctx-ai-chatbot-s3-enriched-data-187091248012"
    acl                      = "private"
    control_object_ownership = true
    object_ownership         = "ObjectWriter"
    versioning               = true
  }
}
