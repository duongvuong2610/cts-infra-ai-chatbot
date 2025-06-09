module "s3" {
  source = "terraform-aws-modules/s3-bucket/aws"

  for_each = var.s3

  bucket                   = each.key
  acl                      = each.value.acl
  control_object_ownership = each.value.control_object_ownership
  object_ownership         = each.value.object_ownership
  versioning = {
    enabled = each.value.versioning
  }
}
