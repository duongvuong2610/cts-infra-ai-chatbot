variable "search_collection" {
  description = "Configuration of an OpenSearch collection - type: SEARCH"

  type = object({
    name             = string
    standby_replicas = string
    type             = string
    encryption_policy = object({
      name        = string
      type        = string
      description = string
      policy      = string # JSON string
    })
    network_policy = object({
      name        = string
      type        = string
      description = string
      policy      = string
    })
    data_access_policy = object({
      name        = string
      type        = string
      description = string
      policy      = string
    })
  })
}

variable "vector_collection" {
  description = "Configuration of an OpenSearch collection - type: VECTORSEARCH"

  type = object({
    name             = string
    standby_replicas = string
    type             = string
    encryption_policy = object({
      name        = string
      type        = string
      description = string
      policy      = string # JSON string
    })
    network_policy = object({
      name        = string
      type        = string
      description = string
      policy      = string
    })
    data_access_policy = object({
      name        = string
      type        = string
      description = string
      policy      = string
    })
  })
}

variable "search_collection_index" {
  description = "Configuration for the OpenSearch Search collection index"

  type = object({
    name               = string
    number_of_shards   = string
    number_of_replicas = string
    force_destroy      = bool
    mappings           = string
  })
}

variable "vector_collection_index" {
  description = "Configuration for the OpenSearch Vector collection index"

  type = object({
    name                           = string
    number_of_shards               = string
    number_of_replicas             = string
    index_knn                      = bool
    index_knn_algo_param_ef_search = string
    force_destroy                  = bool
    mappings                       = string
  })
}
