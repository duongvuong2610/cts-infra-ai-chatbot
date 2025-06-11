variable "s3_source_crawl" {
  description = "S3 bucket names and their configurations"

  type = object({
    bucket                   = string
    acl                      = string
    control_object_ownership = bool
    object_ownership         = string
    versioning               = bool
  })
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
}
