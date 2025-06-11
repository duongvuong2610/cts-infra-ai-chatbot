data "aws_caller_identity" "current" {}

# Create OpenSearch Serverless Collection - TYPE: SEARCH
resource "aws_opensearchserverless_collection" "search_collection" {
  name             = var.search_collection.name
  standby_replicas = var.search_collection.standby_replicas
  type             = var.search_collection.type

  depends_on = [aws_opensearchserverless_security_policy.search_collection_encryption_policy]
}

resource "aws_opensearchserverless_security_policy" "search_collection_encryption_policy" {
  name        = var.search_collection.encryption_policy.name
  type        = var.search_collection.encryption_policy.type
  description = var.search_collection.encryption_policy.description
  policy      = var.search_collection.encryption_policy.policy
}

resource "aws_opensearchserverless_security_policy" "search_collection_network_policy" {
  name        = var.search_collection.network_policy.name
  type        = var.search_collection.network_policy.type
  description = var.search_collection.network_policy.description
  policy      = var.search_collection.network_policy.policy
}

resource "aws_opensearchserverless_access_policy" "search_collection_data_access_policy" {
  name        = var.search_collection.data_access_policy.name
  type        = var.search_collection.data_access_policy.type
  description = var.search_collection.data_access_policy.description
  policy      = var.search_collection.data_access_policy.policy

  depends_on = [
    aws_opensearchserverless_collection.search_collection
  ]
}

# Create OpenSearch Serverless Collection - TYPE: VECTORSEARCH
resource "aws_opensearchserverless_collection" "vector_collection" {
  name             = var.vector_collection.name
  standby_replicas = var.vector_collection.standby_replicas
  type             = var.vector_collection.type

  depends_on = [aws_opensearchserverless_security_policy.vector_collection_encryption_policy]
}

resource "aws_opensearchserverless_security_policy" "vector_collection_encryption_policy" {
  name        = var.vector_collection.encryption_policy.name
  type        = var.vector_collection.encryption_policy.type
  description = var.vector_collection.encryption_policy.description
  policy      = var.vector_collection.encryption_policy.policy
}

resource "aws_opensearchserverless_security_policy" "vector_collection_network_policy" {
  name        = var.vector_collection.network_policy.name
  type        = var.vector_collection.network_policy.type
  description = var.vector_collection.network_policy.description
  policy      = var.vector_collection.network_policy.policy
}

resource "aws_opensearchserverless_access_policy" "vector_collection_data_access_policy" {
  name        = var.vector_collection.data_access_policy.name
  type        = var.vector_collection.data_access_policy.type
  description = var.vector_collection.data_access_policy.description
  policy      = var.vector_collection.data_access_policy.policy

  depends_on = [
    aws_opensearchserverless_collection.vector_collection
  ]
}

# Create OpenSearch Indexes
resource "opensearch_index" "search_collection_index" {
  provider           = opensearch.signed-search
  name               = var.search_collection_index.name
  number_of_shards   = var.search_collection_index.number_of_shards
  number_of_replicas = var.search_collection_index.number_of_replicas
  force_destroy      = var.search_collection_index.force_destroy
  mappings           = var.search_collection_index.mappings

  depends_on = [
    aws_opensearchserverless_collection.search_collection,
    null_resource.wait_for_policy_sync_01
  ]

  lifecycle {
    ignore_changes = [
      mappings # Ignore changes to mappings
    ]
  }
}

resource "opensearch_index" "vector_collection_index" {
  provider                       = opensearch.signed-vector
  name                           = var.vector_collection_index.name
  number_of_shards               = var.vector_collection_index.number_of_shards
  number_of_replicas             = var.vector_collection_index.number_of_replicas
  index_knn                      = var.vector_collection_index.index_knn
  index_knn_algo_param_ef_search = var.vector_collection_index.index_knn_algo_param_ef_search
  force_destroy                  = var.vector_collection_index.force_destroy
  mappings                       = var.vector_collection_index.mappings

  depends_on = [
    aws_opensearchserverless_collection.vector_collection,
    null_resource.wait_for_policy_sync_02
  ]

  lifecycle {
    ignore_changes = [
      mappings # Ignore changes to mappings
    ]
  }
}

# Wait for policy sync
resource "null_resource" "wait_for_policy_sync_01" {
  triggers = {
    access_policy = aws_opensearchserverless_access_policy.search_collection_data_access_policy.id
  }

  provisioner "local-exec" {
    command = "sleep 60"
  }
}

resource "null_resource" "wait_for_policy_sync_02" {
  triggers = {
    access_policy = aws_opensearchserverless_access_policy.vector_collection_data_access_policy.id
  }

  provisioner "local-exec" {
    command = "sleep 60"
  }
}
