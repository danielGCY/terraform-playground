output "placement_group_id" {
  description = "AWS resource ID for placement group"
  value       = aws_placement_group.main.id
}

output "asg_id" {
  description = "AWS resource ID for auto-scaling group"
  value       = aws_autoscaling_group.main.id
}
