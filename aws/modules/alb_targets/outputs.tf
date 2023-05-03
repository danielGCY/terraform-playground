output "target_group_arn" {
  description = "AWS resource ARN for the provisioned target group"
  value       = aws_lb_target_group.main.arn
}

output "listener_arn" {
  description = "AWS resource ARN for the provisioned listener"
  value       = aws_lb_listener.main.arn
}
