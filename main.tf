locals {
  users_arn = [
    "arn:aws:iam::187091248012:user/dvvuong1",
    "arn:aws:iam::187091248012:user/lltien",
    "arn:aws:iam::187091248012:user/lvthinh1"
  ]
}

data "aws_caller_identity" "current" {}

module "vpc" {
  source = "./modules/vpc"

  vpc = {
    name                   = "ctx-ai-chatbot-vpc"
    cidr                   = "10.30.0.0/16"
    azs                    = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
    private_subnets        = ["10.30.1.0/24", "10.30.2.0/24", "10.30.3.0/24"]
    public_subnets         = ["10.30.101.0/24", "10.30.102.0/24", "10.30.103.0/24"]
    enable_nat_gateway     = true
    single_nat_gateway     = true
    one_nat_gateway_per_az = false
  }
}

module "s3" {
  source = "./modules/s3"

  s3_source_crawl = {
    bucket                   = "ctx-ai-chatbot-s3-source-crawl-187091248012"
    acl                      = "private"
    control_object_ownership = true
    object_ownership         = "ObjectWriter"
    versioning               = true
  }

  s3_vector_search = {
    bucket                   = "ctx-ai-chatbot-s3-enriched-data-187091248012"
    acl                      = "private"
    control_object_ownership = true
    object_ownership         = "ObjectWriter"
    versioning               = true
  }
}

module "dynamodb_table" {
  source = "./modules/dynamodb_table"

  dynamodb_table = {
    name     = "ai-chatbot-session-chat"
    hash_key = "id"
    attributes = [
      {
        name = "id"
        type = "N"
      }
    ]
  }
}

module "vpc_endpoints" {
  source = "./modules/vpc_endpoints"

  vpc_id          = module.vpc.vpc_id
  route_table_ids = module.vpc.private_route_table_ids

  s3_endpoint = {
    service_name      = "com.amazonaws.ap-southeast-2.s3"
    vpc_endpoint_type = "Gateway"
  }

  dynamodb_table_endpoint = {
    service_name      = "com.amazonaws.ap-southeast-2.dynamodb"
    vpc_endpoint_type = "Gateway"
  }

  depends_on = [module.vpc]
}

module "ecr" {
  source = "./modules/ecr"

  ecr = {
    repository_name = "ctx-lab/ai-chatbot"
    repository_read_write_access_arns = concat([
      module.iam.ec2_role_arn
    ], local.users_arn)
    repository_lifecycle_policy = {
      rules = [
        {
          rulePriority = 1,
          description  = "Keep last 30 images",
          selection = {
            tagStatus     = "tagged",
            tagPrefixList = ["v"],
            countType     = "imageCountMoreThan",
            countNumber   = 30
          },
          action = {
            type = "expire"
          }
        }
      ]
    }
  }

  depends_on = [module.iam]
}

module "iam" {
  source = "./modules/iam"

  iam_config = {
    ec2 = {
      role_name        = "ecs-ec2-role"
      instance_profile = "ecs-ec2-profile"
    },
    bedrock_knowledge_base = {
      role_name     = "charmander-bedrock-role"
      s3_bucket_arn = module.s3.vector_search_s3_bucket_arn
      foundation_model_arns = [
        "arn:aws:bedrock:ap-southeast-2::foundation-model/cohere.embed-multilingual-v3",
        "arn:aws:bedrock:ap-southeast-2::foundation-model/anthropic.claude-3-5-sonnet-20241022-v2:0",
        "arn:aws:bedrock:ap-southeast-2::foundation-model/anthropic.claude-3-7-sonnet-20250219-v1:0"
      ]
    }
  }

  depends_on = [module.s3]
}

module "sg" {
  source = "./modules/sg"

  vpc_id = module.vpc.vpc_id

  depends_on = [module.vpc]
}

# module "alb" {
#   source = "./modules/alb"

#   vpc_id             = module.vpc.vpc_id
#   subnets            = module.vpc.public_subnets
#   security_group_ids = module.sg.alb_sg_id

#   depends_on = [module.vpc, module.sg]
# }

# module "bedrock" {
#   source = "./modules/bedrock"

#   knowledge_base_config = merge(
#     var.knowledge_base_config,
#     {
#       name                            = local.knowledge_base_name
#       bedrock_knowledge_base_role_arn = module.iam.bedrock_knowledge_base_role_arn
#       opensearch_collection_arn       = module.opensearch_serverless.opensearch_collection_arn
#       vector_index_name               = module.opensearch_serverless.vector_index_name
#     }
#   )

#   data_source_config = merge(
#     var.data_source_config,
#     {
#       bucket_arn = module.s3.s3_bucket_arn
#     }
#   )

#   parsing_configuration  = var.parsing_configuration
#   chunking_configuration = var.chunking_configuration

#   depends_on = [module.opensearch]
# }

# OpenSearch Serverless - OSS
module "opensearch_serverless" {
  source = "./modules/opensearch_serverless"

  search_collection = {
    name             = "search-collection"
    standby_replicas = "DISABLED"
    type             = "SEARCH"
    encryption_policy = {
      name        = "search-collection-encrypt-policy"
      type        = "encryption"
      description = "Encryption security policy for search-collection"
      policy = jsonencode({
        Rules = [
          {
            Resource     = ["collection/search-collection"]
            ResourceType = "collection"
          }
        ],
        AWSOwnedKey = true
      })
    }
    network_policy = {
      name        = "search-collection-network-policy"
      type        = "network"
      description = "Network policy for search-collection"
      policy = jsonencode([
        {
          Description = "Public access to collection and Dashboards endpoint for search-collection",
          Rules = [
            {
              ResourceType = "collection",
              Resource     = ["collection/search-collection"]
            },
            {
              ResourceType = "dashboard",
              Resource     = ["collection/search-collection"]
            }
          ],
          AllowFromPublic = true
        }
      ])
    }
    data_access_policy = {
      name        = "search-collection-access-policy"
      type        = "data"
      description = "Read and write permissions"
      policy = jsonencode([
        {
          Rules = [
            {
              ResourceType = "index",
              Resource     = ["index/search-collection/*"],
              Permission   = ["aoss:*"]
            },
            {
              ResourceType = "collection",
              Resource     = ["collection/search-collection"],
              Permission   = ["aoss:*"]
            }
          ],
          Principal = concat([
            module.iam.ec2_role_arn
          ], local.users_arn)
        }
      ])
    }
  }

  vector_collection = {
    name             = "vector-collection"
    standby_replicas = "DISABLED"
    type             = "VECTORSEARCH"
    encryption_policy = {
      name        = "vector-collection-encrypt-policy"
      type        = "encryption"
      description = "Encryption security policy for vector-collection"
      policy = jsonencode({
        Rules = [
          {
            Resource     = ["collection/vector-collection"]
            ResourceType = "collection"
          }
        ],
        AWSOwnedKey = true
      })
    }
    network_policy = {
      name        = "vector-collection-network-policy"
      type        = "network"
      description = "Network policy for vector-collection"
      policy = jsonencode([
        {
          Description = "Public access to collection and Dashboards endpoint for vector-collection",
          Rules = [
            {
              ResourceType = "collection",
              Resource     = ["collection/vector-collection"]
            },
            {
              ResourceType = "dashboard",
              Resource     = ["collection/vector-collection"]
            }
          ],
          AllowFromPublic = true
        }
      ])
    }
    data_access_policy = {
      name        = "vector-collection-access-policy"
      type        = "data"
      description = "Read and write permissions"
      policy = jsonencode([
        {
          Rules = [
            {
              ResourceType = "index",
              Resource     = ["index/vector-collection/*"],
              Permission   = ["aoss:*"]
            },
            {
              ResourceType = "collection",
              Resource     = ["collection/vector-collection"],
              Permission   = ["aoss:*"]
            }
          ],
          Principal = concat([
            module.iam.bedrock_knowledge_base_role_arn,
            module.iam.ec2_role_arn
          ], local.users_arn)
        }
      ])
    }
  }


  search_collection_index = {
    name               = "search-collection-index"
    number_of_shards   = "2"
    number_of_replicas = "0"
    force_destroy      = true
    mappings           = <<EOF
{
  "properties": {
    "AMAZON_BEDROCK_METADATA": {
      "type": "text",
      "index": true
    },
    "AMAZON_BEDROCK_TEXT_CHUNK": {
      "type": "text",
      "index": true
    }
  }
}
EOF
  }

  vector_collection_index = {
    name                           = "vector-collection-index"
    number_of_shards               = "2"
    number_of_replicas             = "0"
    index_knn                      = true
    index_knn_algo_param_ef_search = "512"
    force_destroy                  = true
    mappings                       = <<EOF
{
  "properties": {
    "bedrock-knowledge-base-default-vector": {
      "type": "knn_vector",
      "dimension": 1024,
      "method": {
        "name": "hnsw",
        "engine": "faiss",
        "parameters": {
          "m": 16,
          "ef_construction": 512
        },
        "space_type": "l2"
      }
    },
    "AMAZON_BEDROCK_METADATA": {
      "type": "text",
      "index": true
    },
    "AMAZON_BEDROCK_TEXT_CHUNK": {
      "type": "text",
      "index": true
    }
  }
}
EOF
  }

}
