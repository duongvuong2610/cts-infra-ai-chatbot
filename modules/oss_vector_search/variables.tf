variable "bedrock_knowledge_base_role_arn" {
  description = "ARN of the Bedrock knowledge base role"
  type        = string
}

variable "opensearch_collection_name" {
  description = "Name of the OpenSearch collection"
  type        = string
  default     = "char-vec-search"
}

variable "opensearch_index_config" {
  description = "Configuration for the OpenSearch index"
  type = object({
    name                           = string
    number_of_shards               = string
    number_of_replicas             = string
    index_knn                      = bool
    index_knn_algo_param_ef_search = string
    force_destroy                  = bool
    mappings                       = string
  })

  default = {
    name                           = "charmander-loptop-index"
    number_of_shards               = "2"
    number_of_replicas             = "0"
    index_knn                      = true
    index_knn_algo_param_ef_search = "512"
    force_destroy                  = true
    mappings                       = <<EOF
{
  "properties": {
    "bedrock-knowledge-base-default-vector": {
      "type": "knn_vector",
      "dimension": 1024,
      "method": {
        "name": "hnsw",
        "engine": "faiss",
        "parameters": {
          "m": 16,
          "ef_construction": 512
        },
        "space_type": "l2"
      }
    },
    "AMAZON_BEDROCK_METADATA": {
      "type": "text",
      "index": true
    },
    "AMAZON_BEDROCK_TEXT_CHUNK": {
      "type": "text",
      "index": true
    }
  }
}
EOF
  }
}
