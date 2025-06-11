output "source_crawl_s3_bucket_arn" {
  description = "ARN of created S3 source crawl"
  value       = module.s3_source_crawl.s3_bucket_arn
}

output "vector_search_s3_bucket_arn" {
  description = "ARN of created S3 vector search"
  value       = module.s3_vector_search.s3_bucket_arn
}
