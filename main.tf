module "vpc" {
  source = "./modules/vpc"
}


module "s3" {
  source = "./modules/s3"
}

# module "ecr" {
#   source = "./modules/ecr"

#   repository_read_write_access_arns = [module.iam.ec2_role_arn]

#   depends_on = [module.iam]
# }

# module "iam" {
#   source = "./modules/iam"
# }

module "dynamodb_table" {
  source = "./modules/dynamodb_table"
}

# module "sg" {
#   source = "./modules/sg"

#   vpc_id     = module.vpc.vpc_id
#   depends_on = [module.vpc]
# }

# module "alb" {
#   source = "./modules/alb"

#   vpc_id             = module.vpc.vpc_id
#   subnets            = module.vpc.public_subnets
#   security_group_ids = module.sg.alb_sg_id

#   depends_on = [module.vpc, module.sg]
# }

module "vpc_endpoints" {
  source = "./modules/vpc_endpoints"

  vpc_id          = module.vpc.vpc_id
  route_table_ids = module.vpc.private_route_table_ids

  depends_on = [module.vpc]
}

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
  source                          = "./modules/opensearch_serverless"
  # bedrock_knowledge_base_role_arn = module.iam.bedrock_knowledge_base_role_arn
  # opensearch_collection_name      = var.opensearch_collection_name
  # opensearch_index_config         = var.opensearch_index_config
}

