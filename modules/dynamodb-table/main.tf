module "dynamodb_table" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name     = var.dynamodb_table.name
  hash_key = var.dynamodb_table.hash_key

  attributes = var.dynamodb_table.attributes

  tags = var.dynamodb_table.tags
}
