output "cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "cluster_id" {
  description = "AWS resource ID for ECS cluster"
  value       = aws_ecs_cluster.main.id
}

output "cluster_arn" {
  value = aws_ecs_cluster.main.arn
}
