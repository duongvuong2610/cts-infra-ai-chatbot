variable "opensearchs" {
  description = "Configuration for creating OpenSearch collections"

  type = map(object({
    description           = string
    type                  = string
    create_access_policy  = bool
    create_network_policy = bool
    tags = object({
      Owner     = string
      Terraform = string
    })
  }))

  default = {
    "full-text-search" = {
      description           = "OpenSearch Collection for full-text search"
      type                  = "SEARCH"
      create_access_policy  = true
      create_network_policy = true
      tags = {
        Owner     = "CTX"
        Terraform = "true"
      }
    },
    "vector-search" = {
      description           = "OpenSearch Collection for storing vector search"
      type                  = "VECTORSEARCH"
      create_access_policy  = true
      create_network_policy = true
      tags = {
        Owner     = "CTX"
        Terraform = "true"
      }
    }
  }
}

variable "opensearch_endpoints" {
  description = "Opensearch VPC endpoints configuration"

  type = map(object({
    subnet_ids = list(string)
    vpc_id = string
  }))
}
