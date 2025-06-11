output "search_collection_arn" {
  value = aws_opensearchserverless_collection.search_collection.arn
}

output "vector_collection_arn" {
  value = aws_opensearchserverless_collection.vector_collection.arn
}

output "vector_collection_index_name" {
  value = opensearch_index.vector_collection_index.name
}