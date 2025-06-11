# Configure the AWS Provider
provider "aws" {
  region = var.region
  profile = var.profile

  default_tags {
    tags = {
      Purpose = "lab-poc"
      Owner     = "CTX"
      Terraform = "true"
    }
  }
}