variable "knowledge_base_config" {
  description = "Configuration for Bedrock Knowledge Base"
  type = object({
    name                            = string
    bedrock_knowledge_base_role_arn = string
    embedding_model_arn             = string
    opensearch_collection_arn       = string
    vector_index_name               = string
    vector_field                    = string
    text_field                      = string
    metadata_field                  = string
    tags                            = map(string)
  })
}

variable "data_source_config" {
  description = "Config for the data source"
  type = object({
    name       = string
    bucket_arn = string
  })
}

variable "parsing_configuration" {
  description = "Parsing configuration for the data source"
  type = object({
    model_arn             = string
    parsing_prompt_string = string
  })
}

variable "chunking_configuration" {
  description = "Chunking configuration for the data source"
  type = object({
    strategy                        = string
    max_token                       = number
    breakpoint_percentile_threshold = number
    buffer_size                     = number
  })
}
