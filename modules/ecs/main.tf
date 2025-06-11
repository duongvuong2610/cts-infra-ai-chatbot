resource "aws_ecs_cluster" "ai-chatbot-cluster" {
  name = var.ecs_cluster.name
}