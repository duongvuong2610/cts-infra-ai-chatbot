provider "opensearch" {
  alias             = "vector-signed"
  url               = aws_opensearchserverless_collection.vector_collection.collection_endpoint
  aws_region        = data.aws_region.current.name
  sign_aws_requests = true
  healthcheck       = false
}

data "aws_region" "current" {}
