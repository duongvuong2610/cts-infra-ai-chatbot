resource "aws_lambda_function" "s3-to-opensearch" {
  description = "Lambda function to move data from S3 to Opensearch"

  function_name = var.lambda_function.function_name
  role          = var.lambda_function.role
  filename      = var.lambda_function.filename
  handler       = var.lambda_function.handler
  runtime       = var.lambda_function.runtime
}
