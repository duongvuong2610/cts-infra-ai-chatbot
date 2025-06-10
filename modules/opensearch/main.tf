module "opensearch" {
  source = "terraform-aws-modules/opensearch/aws//modules/collection"

  for_each = var.opensearchs

  name                  = each.key
  description           = each.value.description
  type                  = each.value.type
  create_access_policy  = each.value.create_access_policy
  create_network_policy = each.value.create_network_policy
  network_policy = {
    AllowFromPublic = false
    SourceVPCEs = [
      aws_opensearchserverless_vpc_endpoint.opensearch_endpoints[each.key].id
    ]
  }
  tags = each.value.tags

  depends_on = [aws_opensearchserverless_vpc_endpoint.opensearch_endpoints]

}

resource "aws_opensearchserverless_vpc_endpoint" "opensearch_endpoints" {
  for_each = var.opensearch_endpoints

  name       = each.key
  subnet_ids = each.value.subnet_ids
  vpc_id     = each.value.vpc_id
}
