output "server_sg_id" {
  value = aws_security_group.server_sg.id
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}