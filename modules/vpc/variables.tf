variable "vpc" {
  description = "Configuration for creating the VPC"

  type = object({
    name               = string
    cidr               = string
    azs                = list(string)
    private_subnets    = list(string)
    public_subnets     = list(string)
    enable_nat_gateway = bool
    single_nat_gateway = bool
    one_nat_gateway_per_az = bool
  })

  default = {
    name               = "ctx-ai-chatbot-vpc"
    cidr               = "10.30.0.0/16"
    azs                = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
    private_subnets    = ["10.30.1.0/24", "10.30.2.0/24", "10.30.3.0/24"]
    public_subnets     = ["10.30.101.0/24", "10.30.102.0/24", "10.30.103.0/24"]
    enable_nat_gateway = true
    single_nat_gateway = true
    one_nat_gateway_per_az = false
  }
}