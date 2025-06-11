variable "route_table_ids" {
  description = "List of IDs of private route tables"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "s3_endpoint" {
  description = "Configuration of S3 Gateway endpoint"

  type = object({
    service_name      = string
    vpc_endpoint_type = string
  })
}

variable "dynamodb_table_endpoint" {
  description = "Configuration of Dynamodb Table Gateway endpoint"

  type = object({
    service_name      = string
    vpc_endpoint_type = string
  })
}
