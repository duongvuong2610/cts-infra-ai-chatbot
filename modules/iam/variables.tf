variable "iam_config" {
  description = "Configuration for IAM roles and policies"
  type = object({
    ec2 = object({
      role_name        = string
      instance_profile = string
    })

    bedrock_knowledge_base = object({
      role_name                 = string
      foundation_model_arns     = list(string)
      opensearch_collection_arn = string
      s3_bucket_arns             = list(string)
    })
  })
  default = {
    ec2 = {
      role_name        = "ecs-ec2-role"
      instance_profile = "ecs-ec2-profile"
    }

  }
}
