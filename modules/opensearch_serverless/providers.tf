provider "opensearch" {
  alias             = "signed-search"
  url               = aws_opensearchserverless_collection.search_collection.collection_endpoint
  aws_region        = data.aws_region.current.name
  sign_aws_requests = true
  healthcheck       = false
}

provider "opensearch" {
  alias             = "signed-vector"
  url               = aws_opensearchserverless_collection.vector_collection.collection_endpoint
  aws_region        = data.aws_region.current.name
  sign_aws_requests = true
  healthcheck       = false
}

data "aws_region" "current" {}
  