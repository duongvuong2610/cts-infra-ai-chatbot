terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.90"
    }

    opensearch = {
      source  = "opensearch-project/opensearch"
      version = ">= 2.0.0"
    }
  }
  
  backend "s3" {
    bucket = "ctx-ai-chatbot-s3-tf-backend-187091248012"
    key    = "terraform.tfstate"
    region       = "ap-southeast-2"
    use_lockfile = true
    profile      = "iac-ai-chatbot"
  }
}
