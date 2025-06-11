resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = var.s3_endpoint.service_name
  route_table_ids   = var.route_table_ids
  vpc_endpoint_type = var.s3_endpoint.vpc_endpoint_type
}

resource "aws_vpc_endpoint" "dynamodb_table_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = var.dynamodb_table_endpoint.service_name
  route_table_ids   = var.route_table_ids
  vpc_endpoint_type = var.dynamodb_table_endpoint.vpc_endpoint_type
}