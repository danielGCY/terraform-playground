output "ecr_repository_url" {
  value = aws_ecr_repository.main[0].repository_url
}

output "ecr_repository_id" {
  value = aws_ecr_repository.main[0].id
}

output "ecr_repository_arn" {
  value = aws_ecr_repository.main[0].arn
}

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
