resource "aws_lambda_function" "s3_to_opensearch" {
  description = "Lambda function to move data from S3 to Opensearch"

  function_name = var.s3_to_opensearch.function_name
  role          = var.s3_to_opensearch.role
  filename      = var.s3_to_opensearch.filename
  handler       = var.s3_to_opensearch.handler
  runtime       = var.s3_to_opensearch.runtime
}

resource "aws_lambda_function" "enrich_job" {
  description = "Enrich job"

  function_name = var.enrich_job.function_name
  role          = var.enrich_job.role
  filename      = var.enrich_job.filename
  handler       = var.enrich_job.handler
  runtime       = var.enrich_job.runtime
}