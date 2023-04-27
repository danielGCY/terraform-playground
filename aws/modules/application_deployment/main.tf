locals {
  ### ECR
  ecr_name = var.create_ecr ? coalesce(var.ecr_name, "${var.name_prefix}-ecr-main") : null
  ecr_tags = merge(var.global_tags, var.ecr_tags)

  ### ECS CLUSTER
  ecs_cluster_name = coalesce(var.ecs_cluster_name, "${var.name_prefix}-ecs-cluster-default")
  ecs_cluster_tags = merge(var.global_tags, var.ecs_cluster_tags)

  ### TASK DEFINITION
  task_definition_family                     = coalesce(var.task_definition_family, "${var.name_prefix}-app")
  task_definition_container_definitions_json = jsondecode(var.task_definition_container_definitions)
  task_definition_tags                       = merge(var.global_tags, var.task_definition_tags)

  ### ECS SERVICE
  service_name             = coalesce(var.service_name, "${var.name_prefix}-ecs-service")
  service_platform_version = var.service_launch_type == "FARGATE" ? var.service_platform_version : null
  ecs_service_tags         = merge(var.global_tags, var.service_tags)
}

resource "aws_ecr_repository" "main" {
  count = var.create_ecr ? 1 : 0

  name         = local.ecr_name
  force_delete = var.force_delete

  tags = var.ecr_tags
}

resource "aws_ecs_cluster" "main" {
  name = local.ecs_cluster_name

  configuration {
    execute_command_configuration {
      logging    = var.ecs_cluster_log_configuration != null ? "OVERRIDE" : "DEFAULT"
      kms_key_id = var.ecs_cluster_kms_key_id

      dynamic "log_configuration" {
        for_each = var.ecs_cluster_log_configuration != null ? [var.ecs_cluster_log_configuration] : []

        content {
          cloud_watch_encryption_enabled = log_configuration.cloud_watch_encryption_enabled
          cloud_watch_log_group_name     = log_configuration.cloud_watch_log_group_name
          s3_bucket_name                 = log_configuration.s3_bucket_name
          s3_bucket_encryption_enabled   = log_configuration.s3_bucket_encryption_enabled
          s3_key_prefix                  = log_configuration.s3_key_prefix
        }
      }
    }
  }

  tags = local.ecs_cluster_tags
}

resource "aws_ecs_cluster_capacity_providers" "default" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = [var.ecs_provider == "FARGATE" ? var.ecs_provider : aws_ecs_capacity_provider.default[0].name]
}

resource "aws_ecs_capacity_provider" "default" {
  count = var.ecs_provider == "EC2" ? 1 : 0

  name = "${var.name_prefix}-ecs-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = var.asg_arn
  }

  lifecycle {
    precondition {
      condition     = var.ecs_provider != "EC2" ? true : var.asg_arn != null
      error_message = "Variable `asg_arn` must be defined if `ecs_provider` is \"EC2\""
    }
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = local.task_definition_family
  container_definitions    = var.reference_created_ecr ? jsonencode([for definition in local.task_definition_container_definitions_json : merge({ image = "${resource.aws_ecr_repository.main[0].repository_url}:${var.image_tag}" }, definition)]) : jsonencode(var.task_definition_container_definitions)
  network_mode             = var.task_definition_network_mode
  requires_compatibilities = [var.task_definition_required_compatibilities]
  cpu                      = var.task_definition_cpu
  memory                   = var.task_definition_memory
  execution_role_arn       = var.task_definition_execution_role_arn
  ipc_mode                 = var.task_definition_ipc_mode
  pid_mode                 = var.task_definition_pid_mode
  skip_destroy             = var.task_definition_skip_destroy
  task_role_arn            = var.task_definition_task_role_arn

  dynamic "volume" {
    for_each = var.task_definition_volume != null ? [1] : []

    content {
      name      = volume.value["name"]
      host_path = volume.value["host_path"]
    }
  }

  dynamic "placement_constraints" {
    for_each = coalesce(var.task_definition_placement_constraints, [])

    content {
      expression = placement_constraints.value["expression"]
      type       = placement_constraints.value["type"]
    }
  }

  tags = local.task_definition_tags

  lifecycle {
    precondition {
      condition     = var.reference_created_ecr ? var.create_ecr : true
      error_message = "Variable `create_ecr` must be true if `reference_created_ecr` is specified"
    }
    precondition {
      condition     = var.ecs_provider != "FARGATE" ? true : var.task_definition_cpu != null
      error_message = "Variable `task_definition_cpu` must be defined when `task_definition_required_compatibilities` is \"FARGATE\""
    }

    precondition {
      condition     = var.ecs_provider != "FARGATE" ? true : var.task_definition_memory != null
      error_message = "Variable `task_definition_memory` must be defined when `task_definition_required_compatibilities` is \"FARGATE\""
    }
  }

  depends_on = [aws_ecr_repository.main]
}

resource "aws_ecs_service" "main" {
  name                              = local.service_name
  cluster                           = aws_ecs_cluster.main.id
  task_definition                   = aws_ecs_task_definition.main.arn
  desired_count                     = var.desired_instance_count
  enable_ecs_managed_tags           = var.enable_ecs_managed_tags
  enable_execute_command            = var.enable_execute_command
  force_new_deployment              = var.force_new_deployment
  health_check_grace_period_seconds = var.health_check_grace_period_seconds
  iam_role                          = var.service_iam_role
  launch_type                       = var.service_launch_type
  platform_version                  = local.service_platform_version
  propagate_tags                    = var.service_propagate_tags
  scheduling_strategy               = var.service_scheduling_strategy
  triggers                          = var.service_triggers
  wait_for_steady_state             = var.service_wait_for_steady_state

  dynamic "alarms" {
    for_each = var.service_alarms != null ? [var.service_alarms] : []

    content {
      alarm_names = alarms.value.alarm_names
      enable      = alarms.value.enable
      rollback    = alarms.value.rollback
    }
  }

  dynamic "load_balancer" {
    for_each = var.service_load_balancer != null ? [var.service_load_balancer] : []

    content {
      elb_name         = load_balancer.value["elb_name"]
      target_group_arn = load_balancer.value["target_group_arn"]
      container_name   = load_balancer.value["container_name"]
      container_port   = load_balancer.value["container_port"]
    }
  }

  dynamic "network_configuration" {
    for_each = var.task_definition_network_mode == "awsvpc" ? [var.service_network_configuration] : []

    content {
      subnets          = network_configuration.value["subnets"]
      security_groups  = network_configuration.value["security_groups"]
      assign_public_ip = network_configuration.value["assign_public_ip"]
    }
  }

  dynamic "ordered_placement_strategy" {
    for_each = coalesce(var.service_ordered_placement_strategies, [])

    content {
      type  = ordered_placement_strategy.value["type"]
      field = ordered_placement_strategy.value["field"]
    }
  }

  dynamic "placement_constraints" {
    for_each = coalesce(var.service_placement_constraints, [])

    content {
      expression = placement_constraints.value["expression"]
      type       = placement_constraints.value["type"]
    }
  }

  dynamic "service_registries" {
    for_each = var.service_registries != null ? [var.service_registries] : []

    content {
      registry_arn = service_registries.value["registry_arn"]
      port         = service_registries.value["port"]
    }
  }

  tags = local.ecs_service_tags

  lifecycle {
    precondition {
      condition     = var.task_definition_network_mode != "awsvpc" ? true : var.service_network_configuration != null
      error_message = "Variable `service_network_configuration` must be specified if `task_definition_network_mode` is \"awsvpc\""
    }

    precondition {
      condition     = var.service_launch_type != "FARGATE" ? true : var.service_scheduling_strategy != "DAEMON"
      error_message = "\"DAEMON\" scheduling strategy cannot be used with services with launch_type \"FARGATE\""
    }
  }
}
