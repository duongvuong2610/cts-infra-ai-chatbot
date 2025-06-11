data "aws_caller_identity" "current" {}

# Create OpenSearch Serverless Collection
resource "aws_opensearchserverless_collection" "vector_collection" {
  name             = var.opensearch_collection_name
  standby_replicas = "DISABLED"
  type             = "VECTORSEARCH"

  depends_on = [aws_opensearchserverless_security_policy.vector_encryption_policy]
}

# Create Encryption Security Policy
resource "aws_opensearchserverless_security_policy" "vector_encryption_policy" {
  name        = "${var.opensearch_collection_name}-encrypt-policy"
  type        = "encryption"
  description = "encryption security policy for ${var.opensearch_collection_name}"

  policy = jsonencode({
    Rules = [
      {
        Resource     = ["collection/${var.opensearch_collection_name}"]
        ResourceType = "collection"
      }
    ],
    AWSOwnedKey = true
  })
}

# Create Network Security Policy
resource "aws_opensearchserverless_security_policy" "vector_network_policy" {
  name        = "${var.opensearch_collection_name}-network-policy"
  type        = "network"
  description = "Public access"

  policy = jsonencode([
    {
      Description = "Public access to collection and Dashboards endpoint for ${var.opensearch_collection_name}",
      Rules = [
        {
          ResourceType = "collection",
          Resource     = ["collection/${var.opensearch_collection_name}"]
        },
        {
          ResourceType = "dashboard",
          Resource     = ["collection/${var.opensearch_collection_name}"]
        }
      ],
      AllowFromPublic = true
    }
  ])
}

# Create Data Access Policy
resource "aws_opensearchserverless_access_policy" "vector_data_access_policy" {
  name        = "${var.opensearch_collection_name}-access-policy"
  type        = "data"
  description = "read and write permissions"

  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "index",
          Resource     = ["index/${var.opensearch_collection_name}/*"],
          Permission   = ["aoss:*"]
        },
        {
          ResourceType = "collection",
          Resource     = ["collection/${var.opensearch_collection_name}"],
          Permission   = ["aoss:*"]
        }
      ],
      Principal = [
        data.aws_caller_identity.current.arn,
        "arn:aws:iam::187091248012:user/lltien",
        "arn:aws:iam::187091248012:user/lvthinh1",
        "${var.bedrock_knowledge_base_role_arn}"
      ]
    }
  ])

  depends_on = [
    aws_opensearchserverless_collection.vector_collection
  ]
}

# Create OpenSearch Index
resource "opensearch_index" "vector_index" {
  provider                       = opensearch.vector-signed
  name                           = var.opensearch_index_config.name
  number_of_shards               = var.opensearch_index_config.number_of_shards
  number_of_replicas             = var.opensearch_index_config.number_of_replicas
  index_knn                      = var.opensearch_index_config.index_knn
  index_knn_algo_param_ef_search = var.opensearch_index_config.index_knn_algo_param_ef_search
  force_destroy                  = var.opensearch_index_config.force_destroy
  mappings                       = var.opensearch_index_config.mappings

  depends_on = [
    aws_opensearchserverless_collection.vector_collection,
    null_resource.wait_for_policy_sync
  ]

  lifecycle {
    ignore_changes = [
      mappings # Ignore changes to mappings
    ]
  }
}

# Wait for policy sync
resource "null_resource" "wait_for_policy_sync" {
  triggers = {
    access_policy = aws_opensearchserverless_access_policy.vector_data_access_policy.id
  }

  provisioner "local-exec" {
    command = "sleep 60"
  }
}

