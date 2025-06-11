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
    },
    lambda = {
      role_name = "charmander-lambda-role"
    }
  }

  depends_on = [module.s3]
}

module "sg" {
  source = "./modules/sg"

  vpc_id = module.vpc.vpc_id

  depends_on = [module.vpc]
}

module "bedrock" {
  source = "./modules/bedrock"

  knowledge_base_config = {
    name                            = "ai-chatbot-knowledge-base"
    bedrock_knowledge_base_role_arn = module.iam.bedrock_knowledge_base_role_arn
    embedding_model_arn             = "arn:aws:bedrock:ap-southeast-2::foundation-model/cohere.embed-multilingual-v3"
    opensearch_collection_arn       = module.opensearch_serverless.vector_collection_arn
    vector_index_name               = module.opensearch_serverless.vector_collection_index_name
    vector_field                    = "bedrock-knowledge-base-default-vector"
    text_field                      = "AMAZON_BEDROCK_TEXT_CHUNK"
    metadata_field                  = "AMAZON_BEDROCK_METADATA"
    tags                            = {}
  }

  data_source_config = {
    name       = "S3-data-source"
    bucket_arn = module.s3.vector_search_s3_bucket_arn
  }

  parsing_configuration = {
    model_arn             = "arn:aws:bedrock:ap-southeast-2::foundation-model/anthropic.claude-3-7-sonnet-20250219-v1:0"
    parsing_prompt_string = <<-PROMPT
      Bạn là trợ lý giúp phân loại vào đọc dữ liệu từ ảnh đầu vào.
      ## Mục tiêu
      Phân tích file ảnh được cung cấp, xác định loại ảnh và trích xuất mọi thông tin dạng văn bản hoặc nội dung có ý nghĩa.

      ## Định nghĩa các loại ảnh
      Hãy phân tích file ảnh đầu vào và xác định ảnh thuộc một trong năm loại sau đây:

      1. **Ảnh chứa văn bản (Text Images)**: Ảnh chủ yếu chứa nội dung văn bản như tài liệu, thông báo, đoạn văn, vv. Các nội dung này cần được nhận dạng và trích xuất đầy đủ, giữ nguyên cấu trúc và định dạng khi có thể.

      2. **Biểu đồ/Sơ đồ (Charts/Diagrams)**: Ảnh chứa flowchart, sơ đồ quy trình, biểu đồ tổ chức, mind map, hoặc các biểu đồ diễn giải mối quan hệ. Cần nhận diện cấu trúc logic, các nút (nodes), liên kết (connections), và trình tự của quy trình.

      3. **Ảnh minh họa nghiệp vụ (Business Illustrations)**: Ảnh miêu tả hoạt động nghiệp vụ, thủ tục công việc, hoặc tình huống thực tế trong môi trường làm việc. Cần mô tả chi tiết các hoạt động, đối tượng, và ngữ cảnh.

      4. **Ảnh chứa bảng biểu (Tables)**: Ảnh chứa dữ liệu được tổ chức thành hàng và cột. Cần trích xuất thành cấu trúc bảng rõ ràng, giữ nguyên mối quan hệ giữa các ô dữ liệu.

      5. **Ảnh chứa ký hiệu/công thức đặc thù (Specialized Symbols/Formulas)**: Ảnh chứa công thức toán học, ký hiệu khoa học, phương trình, hoặc ký hiệu chuyên ngành. Cần trích xuất và diễn giải ký hiệu chính xác.

      ## Yêu cầu phân tích và trích xuất

      ### Bước 1: Phân loại ảnh
      - Xác định ảnh đầu vào thuộc loại nào trong năm loại trên
      - Cung cấp lý do chi tiết tại sao ảnh được xếp vào loại đó
      - Nếu ảnh có thể thuộc nhiều loại, hãy xác định loại chính và loại phụ

      ### Bước 2: Trích xuất nội dung
      Dựa trên loại ảnh đã xác định, trích xuất thông tin theo hướng dẫn sau:

      **Đối với ảnh chứa văn bản:**
      - Trích xuất toàn bộ văn bản có trong ảnh
      - Giữ nguyên cấu trúc đoạn văn, dòng, và định dạng quan trọng
      - Nhận diện và phân biệt tiêu đề, phụ đề, nội dung chính bằng markdown.
      - Đánh dấu những phần văn bản không thể đọc được (nếu có)

      **Đối với biểu đồ/sơ đồ:**
      - Trích xuất tên biểu đồ nếu có.
      - Tái tạo cấu trúc biểu đồ bằng văn bản hoặc định dạng markdown khi có thể.
      - Mô tả luồng hoạt động của biểu đồ.

      **Đối với ảnh minh họa nghiệp vụ:**
      - Mô tả tổng quan về tình huống/hoạt động được minh họa
      - Nhận diện các đối tượng, người, vật, địa điểm trong ảnh
      - Giải thích bối cảnh và ý nghĩa của hoạt động
      - Trích xuất mọi văn bản hoặc nhãn đi kèm

      **Đối với ảnh chứa bảng biểu:**
      - Tái tạo cấu trúc bảng hoàn chỉnh dưới dạng văn bản hoặc markdown
      - Đảm bảo căn chỉnh đúng các cột
      - Trích xuất tiêu đề bảng, tiêu đề cột, và tất cả dữ liệu trong ô
      - Giữ nguyên định dạng số (nếu có thể nhận diện)

      **Đối với ảnh chứa ký hiệu/công thức đặc thù:**
      - Trích xuất công thức hoặc ký hiệu bằng định dạng LaTeX hoặc cú pháp phù hợp
      - Giải thích ý nghĩa của công thức/ký hiệu nếu có thể
      - Diễn giải các biến số hoặc ký hiệu đặc biệt
      - Liên hệ công thức với ngữ cảnh của ảnh (nếu có)

      ## Format trình bày:
      - Loại ảnh (không cần nêu lý do phân loại).
      - Thông tin trích rút (Tuân thủ theo bước 2 đối với từng loại ảnh)
    PROMPT
  }

  chunking_configuration = {
    strategy                        = "SEMANTIC"
    max_token                       = 512
    breakpoint_percentile_threshold = 95
    buffer_size                     = 0
  }

  depends_on = [module.opensearch_serverless, module.iam]
}

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

module "event_bridge" {
  source = "./modules/event_bridge"
}

module "lambda" {
  source = "./modules/lambda"

  lambda_function = {
    function_name = "s3-to-opensearch"
    role          = module.iam.lambda_role_arn
    filename      = "./modules/lambda/lambda.zip"
    handler       = "index.handler"
    runtime       = "python3.9"
  }

  depends_on = [module.iam]
}

module "ecs" {
  source = "./modules/ecs"

  ecs_cluster = {
    name = "ai-chatbot-cluster"
  }
}

module "ec2" {
  source = "./modules/ec2"

  ec2_instance = {
    name                   = "ai-chatbot-ec2"
    subnet_id              = element(module.vpc.private_subnets, 0)
    instance_type          = "m5.large"
    ami                    = "ami-00543daa0ad4d3ea4"
    vpc_security_group_ids = [module.sg.server_sg_id]
  }

  depends_on = [module.vpc, module.sg]
}

module "alb" {
  source = "./modules/alb"

  alb = {
    name            = "ai-chatbot-alb"
    vpc_id          = module.vpc.vpc_id
    subnets         = module.vpc.public_subnets
    security_groups = [module.sg.alb_sg_id]
  }

  depends_on = [module.vpc, module.sg]
}
