resource "aws_iam_role" "ec2_role" {
  name = var.iam_config.ec2.role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Sid       = "",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "attach_bedrock_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonBedrockFullAccess"
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "attach_opensearch_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonOpenSearchServiceFullAccess"
}

resource "aws_iam_role_policy_attachment" "attach_dynamodb_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess_v2"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = var.iam_config.ec2.instance_profile
  role = aws_iam_role.ec2_role.name
}

# IAM Role for Bedrock
resource "aws_iam_role" "bedrock_knowledge_base_role" {
  name = var.iam_config.bedrock_knowledge_base.role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid       = "AllowBedrockService",
      Effect    = "Allow",
      Action    = "sts:AssumeRole",
      Principal = { Service = "bedrock.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "bedrock_model_policy" {
  name = "FoundationModelPolicy"
  role = aws_iam_role.bedrock_knowledge_base_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid      = "BedrockInvokeModelStatement",
      Effect   = "Allow",
      Action   = ["bedrock:InvokeModel"],
      Resource = var.iam_config.bedrock_knowledge_base.foundation_model_arns
    }]
  })
}

resource "aws_iam_role_policy" "bedrock_opensearch_policy" {
  name = "OSSPolicy"
  role = aws_iam_role.bedrock_knowledge_base_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid      = "OpenSearchAccess",
      Effect   = "Allow",
      Action   = ["aoss:APIAccessAll"],
      Resource = ["*"]
    }]
  })
}

resource "aws_iam_role_policy" "s3_policy" {
  name = "S3Policy"
  role = aws_iam_role.bedrock_knowledge_base_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid    = "AllowAllS3Actions",
      Effect = "Allow",
      Action = "s3:*",
      Resource = [
        var.s3_bucket_arn,
        "${var.s3_bucket_arn}/*"
      ]
    }]
  })
}
