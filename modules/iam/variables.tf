variable "iam_config" {
  description = "Configuration for IAM roles and policies"
  type = object({
    ec2 = object({
      role_name        = string
      instance_profile = string
    }),
    bedrock_knowledge_base = object({
      role_name             = string
      foundation_model_arns = list(string)
      s3_bucket_arn         = string
    }),
    lambda = object({
      role_name = string
    })
  })
}
