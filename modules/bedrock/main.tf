resource "aws_bedrockagent_knowledge_base" "example-knowledge-base" {
  # This resource creates a knowledge base for Bedrock.
  name     = var.knowledge_base_config.name
  role_arn = var.knowledge_base_config.bedrock_knowledge_base_role_arn
  knowledge_base_configuration {
    vector_knowledge_base_configuration {
      embedding_model_arn = var.knowledge_base_config.embedding_model_arn
    }
    type = "VECTOR"
  }

  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"
    opensearch_serverless_configuration {
      collection_arn    = var.knowledge_base_config.opensearch_collection_arn
      vector_index_name = var.knowledge_base_config.vector_index_name
      field_mapping {
        vector_field   = var.knowledge_base_config.vector_field
        text_field     = var.knowledge_base_config.text_field
        metadata_field = var.knowledge_base_config.metadata_field
      }
    }
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_bedrockagent_data_source" "data-source" {
  knowledge_base_id = aws_bedrockagent_knowledge_base.example-knowledge-base.id
  name              = var.data_source_config.name

  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = var.data_source_config.bucket_arn
    }
  }

  data_deletion_policy = "DELETE"

  # Replace the blocks with attributes
  vector_ingestion_configuration {
    parsing_configuration {
      parsing_strategy = "BEDROCK_FOUNDATION_MODEL"
      bedrock_foundation_model_configuration {
        model_arn = var.parsing_configuration.model_arn
        parsing_prompt{
          parsing_prompt_string = var.parsing_configuration.parsing_prompt_string
        }
      }
    }
    
    chunking_configuration {
      chunking_strategy = var.chunking_configuration.strategy
      semantic_chunking_configuration {
        max_token            = var.chunking_configuration.max_token
        breakpoint_percentile_threshold   = var.chunking_configuration.breakpoint_percentile_threshold
        buffer_size                       = var.chunking_configuration.buffer_size
      }
    }
  }
}