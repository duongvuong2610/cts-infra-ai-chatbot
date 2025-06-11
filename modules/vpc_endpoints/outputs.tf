output "s3_endpoint_id" {
  description = "ID of the AWS S3 endpoint"
  value       = aws_vpc_endpoint.s3_endpoint.id
}

output "dynamodb_table_endpoint_id" {
  description = "ID of the AWS Dynamodb Table endpoint"
  value       = aws_vpc_endpoint.dynamodb_table_endpoint.id
}
