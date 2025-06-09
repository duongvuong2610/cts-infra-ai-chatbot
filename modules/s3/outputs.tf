output "s3_bucket_ids" {
  description = "Map of created S3 bucket names"
  value = { for k, v in module.s3 : k => v.s3_bucket_id }
}