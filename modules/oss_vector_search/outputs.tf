output "opensearch_collection_arn" {
  description = "The ARN of the OpenSearch collection"
  value = aws_opensearchserverless_collection.vector_collection.arn
}

output "vector_index_name" {
  description = "The name of the OpenSearch index"
  value = opensearch_index.vector_index.name
}