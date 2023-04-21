terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  experiments = [module_variable_optional_attrs]
}

provider "aws" {
  region = var.region
}

resource "aws_ecs_cluster" "main" {
  name = "${var.name_prefix}-ecs-cluster-${var.cluster_name}"

  configuration {
    execute_command_configuration {
      logging    = var.log_configuration != null ? "OVERRIDE" : "DEFAULT"
      kms_key_id = var.kms_key_id

      dynamic "log_configuration" {
        for_each = var.log_configuration != null ? [1] : []

        content {
          cloud_watch_encryption_enabled = var.log_configuration.cloud_watch_encryption_enabled
          cloud_watch_log_group_name     = var.log_configuration.cloud_watch_log_group_name
          s3_bucket_name                 = var.log_configuration.s3_bucket_name
          s3_bucket_encryption_enabled   = var.log_configuration.s3_bucket_encryption_enabled
          s3_key_prefix                  = var.log_configuration.s3_key_prefix
        }
      }
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "default" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = [var.ecs_provider == "FARGATE" ? var.ecs_provider : aws_ecs_capacity_provider.default.name]
}

resource "aws_ecs_capacity_provider" "default" {
  name = "${var.name_prefix}-ecs-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = var.asg_arn
  }
}
