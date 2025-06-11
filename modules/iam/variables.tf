variable "iam_config" {
  description = "Configuration for IAM roles and policies"
  type = object({
    ec2 = object({
      role_name        = string
      instance_profile = string
    }),
    bedrock_knowledge_base = object({
      role_name                 = string
      foundation_model_arns     = list(string)
    })
  })

  default = {
    ec2 = {
      role_name        = "ecs-ec2-role"
      instance_profile = "ecs-ec2-profile"
    },
    bedrock_knowledge_base = {
      role_name = "charmander-bedrock-role"
      foundation_model_arns = [
        "arn:aws:bedrock:ap-southeast-2::foundation-model/cohere.embed-multilingual-v3",
        "arn:aws:bedrock:ap-southeast-2::foundation-model/anthropic.claude-3-5-sonnet-20241022-v2:0",
        "arn:aws:bedrock:ap-southeast-2::foundation-model/anthropic.claude-3-7-sonnet-20250219-v1:0"
      ]
    }

  }
}

variable "s3_bucket_arn" {
  description = "The ARN of created S3 vector search"
  type = string
}