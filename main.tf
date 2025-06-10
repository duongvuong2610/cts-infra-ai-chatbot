module "vpc" {
  source = "./modules/vpc"
}

module "s3" {
  source = "./modules/s3"
}

module "ecr" {
  source = "./modules/ecr"
}

module "dynamodb_table" {
  source = "./modules/dynamodb-table"
}

module "sg" {
  source = "./modules/sg"

  vpc_id     = module.vpc.vpc_id
  depends_on = [module.vpc]
}

module "alb" {
  source = "./modules/alb"

  vpc_id = module.vpc.vpc_id
  subnets = module.vpc.public_subnets
  security_group_ids = module.sg.alb_sg_id

  depends_on = [ module.vpc, module.sg ]
}

module "opensearch" {
  source = "./modules/opensearch"

  opensearch_endpoints = {
    "full-text-search" = {
      subnet_ids = module.vpc.private_subnets
      vpc_id     = module.vpc.vpc_id
    },
    "vector-search" = {
      subnet_ids = module.vpc.private_subnets
      vpc_id     = module.vpc.vpc_id
    }
  }

  depends_on = [module.vpc]
}

