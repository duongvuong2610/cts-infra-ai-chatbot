variable "s3_to_opensearch" {
  description = "Configuration of lambda function"

  type = object({
    function_name = string
    role          = string
    filename      = string
    handler       = string
    runtime       = string
  })
}

variable "enrich_job" {
  description = "Configuration of lambda function"

  type = object({
    function_name = string
    role          = string
    filename      = string
    handler       = string
    runtime       = string
  })
}