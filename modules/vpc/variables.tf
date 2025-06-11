variable "vpc" {
  description = "Configuration for creating the VPC"

  type = object({
    name                   = string
    cidr                   = string
    azs                    = list(string)
    private_subnets        = list(string)
    public_subnets         = list(string)
    enable_nat_gateway     = bool
    single_nat_gateway     = bool
    one_nat_gateway_per_az = bool
  })
}
