variable "region" {
  type    = string
  default = "ap-southeast-2"
}

variable "profile" {
  type = string
  default = "iac-ai-chatbot"
}

# Bedrock
variable "knowledge_base_config" {
  description = "Configuration for Bedrock Knowledge Base"
  type = object({
    embedding_model_arn       = string
    vector_field              = string
    text_field                = string
    metadata_field            = string
    tags                     = map(string)
  })

  default = null
}

variable "data_source_config" {
  description = "Configuration object for Bedrock Data Source"
  type = object({
    name       = string
  })

  default = null
}

variable "parsing_configuration" {
  description = "Parsing configuration for the data source"
  type = object({
    model_arn             = string
    parsing_prompt_string = string
  })

  default = null
}

variable "chunking_configuration" {
  description = "Chunking configuration for the data source"
  type = object({
    strategy                        = string
    max_token                       = number
    breakpoint_percentile_threshold = number
    buffer_size                     = number
  })

  default = null
}
