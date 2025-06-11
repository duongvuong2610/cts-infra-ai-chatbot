output "ec2_role_arn" {
  value = aws_iam_role.ec2_role.arn
}

output "bedrock_knowledge_base_role_arn" {
  value = aws_iam_role.bedrock_knowledge_base_role.arn
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}