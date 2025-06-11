provider "opensearch" {
  alias             = "signed"
  url               = aws_opensearchserverless_collection.example-collection.collection_endpoint
  aws_region        = data.aws_region.current.name
  sign_aws_requests = true
  healthcheck       = false
}

data "aws_region" "current" {}
