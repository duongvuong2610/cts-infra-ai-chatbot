module "s3_source_crawl" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket                   = var.s3_source_crawl.bucket
  acl                      = var.s3_source_crawl.acl
  control_object_ownership = var.s3_source_crawl.control_object_ownership
  object_ownership         = var.s3_source_crawl.object_ownership
  versioning = {
    enabled = var.s3_source_crawl.versioning
  }
}

module "s3_vector_search" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket                   = var.s3_vector_search.bucket
  acl                      = var.s3_vector_search.acl
  control_object_ownership = var.s3_vector_search.control_object_ownership
  object_ownership         = var.s3_vector_search.object_ownership
  versioning = {
    enabled = var.s3_vector_search.versioning
  }
}
