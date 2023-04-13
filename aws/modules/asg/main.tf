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

resource "aws_placement_group" "main" {
  name     = "${var.name_prefix}-placement-group"
  strategy = var.placement_strategy
}

resource "aws_autoscaling_group" "main" {
  name                      = "${var.name_prefix}-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  placement_group           = aws_placement_group.main.id
  vpc_zone_identifier       = var.subnet_ids
  force_delete              = var.force_delete
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period
  enabled_metrics           = var.enabled_metrics
  service_linked_role_arn   = try(var.service_linked_role_arn, null)
  target_group_arns         = var.target_group_arns

  dynamic "launch_template" {
    for_each = var.instance_distribution != null || var.mixed_policies_launch_template != null ? [] : [1]

    content {
      id      = var.launch_template_id
      version = "$Latest"
    }
  }
  # launch_template {
  #   id      = var.launch_template_id
  #   version = "$Latest"
  # }

  dynamic "mixed_instances_policy" {
    for_each = var.instance_distribution != null || var.mixed_policies_launch_template != null ? [1] : []

    content {
      dynamic "instances_distribution" {
        for_each = var.instance_distribution != null ? [1] : []

        content {
          on_demand_allocation_strategy            = try(var.instance_distribution.on_demand_allocation_strategy, null)
          on_demand_base_capacity                  = try(var.instance_distribution.on_demand_base_capacity, null)
          on_demand_percentage_above_base_capacity = try(var.instance_distribution.on_demand_percentage_above_base_capacity, null)
          spot_allocation_strategy                 = try(var.instance_distribution.spot_allocation_strategy, null)
          spot_instance_pools                      = try(var.instance_distribution.spot_instance_pools, null)
          spot_max_price                           = try(var.instance_distribution.spot_max_price, null)
        }
      }

      dynamic "launch_template" {
        for_each = var.mixed_policies_launch_template != null ? [1] : []

        content {
          launch_template_specification {
            launch_template_id = var.mixed_policies_launch_template.launch_template_specification.launch_template_id
            version            = var.mixed_policies_launch_template.launch_template_specification.version
          }

          dynamic "override" {
            for_each = var.mixed_policies_launch_template.overrides != null ? var.mixed_policies_launch_template.overrides : []

            content {
              instance_type     = override.value.instance_type
              weighted_capacity = override.value.weighted_capacity

              dynamic "launch_template_specification" {
                for_each = override.value.launch_template_specification != null ? [1] : []

                content {
                  launch_template_id = override.value.launch_template_specification.launch_template_id
                  version            = override.value.launch_template_specification.version
                }
              }

              dynamic "instance_requirements" {
                for_each = override.value.instance_requirements != null ? [1] : []

                content {
                  dynamic "accelerator_count" {
                    for_each = override.value.instance_requirements.accelerator_count != null ? [1] : []

                    content {
                      min = override.value.instance_requirements.accelerator_count.min
                      max = override.value.instance_requirements.accelerator_count.max
                    }
                  }
                  accelerator_manufacturers = override.value.instance_requirements.accelerator_manufacturers
                  accelerator_names         = override.value.instance_requirements.accelerator_names
                  dynamic "accelerator_total_memory_mib" {
                    for_each = override.value.instance_requirements.accelerator_total_memory_mib != null ? [1] : []

                    content {
                      min = override.value.instance_requirements.accelerator_total_memory_mib.min
                      max = override.value.instance_requirements.accelerator_total_memory_mib.max
                    }
                  }
                  accelerator_types      = override.value.instance_requirements.accelerator_types
                  allowed_instance_types = override.value.instance_requirements.allowed_instance_types
                  bare_metal             = override.value.instance_requirements.bare_metal
                  dynamic "baseline_ebs_bandwidth_mbps" {
                    for_each = override.value.instance_requirements.baseline_ebs_bandwidth_mbps != null ? [1] : []

                    content {
                      min = override.value.instance_requirements.baseline_ebs_bandwidth_mbps.min
                      max = override.value.instance_requirements.baseline_ebs_bandwidth_mbps.max
                    }
                  }
                  burstable_performance   = override.value.instance_requirements.burstable_performance
                  cpu_manufacturers       = override.value.instance_requirements.cpu_manufacturers
                  excluded_instance_types = override.value.instance_requirements.excluded_instance_types
                  instance_generations    = override.value.instance_requirements.instance_generations
                  local_storage           = override.value.instance_requirements.local_storage
                  local_storage_types     = override.value.instance_requirements.local_storage_types
                  dynamic "memory_gib_per_vcpu" {
                    for_each = override.value.instance_requirements.memory_gib_per_vcpu != null ? [1] : []

                    content {
                      min = override.value.instance_requirements.memory_gib_per_vcpu.min
                      max = override.value.instance_requirements.memory_gib_per_vcpu.max
                    }
                  }
                  dynamic "memory_mib" {
                    for_each = override.value.instance_requirements.memory_mib != null ? [1] : []

                    content {
                      min = override.value.instance_requirements.memory_mib.min
                      max = override.value.instance_requirements.memory_mib.max
                    }
                  }
                  dynamic "network_bandwidth_gbps" {
                    for_each = override.value.instance_requirements.network_bandwidth_gbps != null ? [1] : []

                    content {
                      min = override.value.instance_requirements.network_bandwidth_gbps.min
                      max = override.value.instance_requirements.network_bandwidth_gbps.max
                    }
                  }
                  dynamic "network_interface_count" {
                    for_each = override.value.instance_requirements.network_interface_count != null ? [1] : []

                    content {
                      min = override.value.instance_requirements.network_interface_count.min
                      max = override.value.instance_requirements.network_interface_count.max
                    }
                  }
                  on_demand_max_price_percentage_over_lowest_price = override.value.instance_requirements.on_demand_max_price_percentage_over_lowest_price
                  require_hibernate_support                        = override.value.instance_requirements.require_hibernate_support
                  spot_max_price_percentage_over_lowest_price      = override.value.instance_requirements.spot_max_price_percentage_over_lowest_price
                  dynamic "total_local_storage_gb" {
                    for_each = override.value.instance_requirements.total_local_storage_gb != null ? [1] : []

                    content {
                      min = override.value.instance_requirements.total_local_storage_gb.min
                      max = override.value.instance_requirements.total_local_storage_gb.max
                    }
                  }
                  dynamic "vcpu_count" {
                    for_each = override.value.instance_requirements.vcpu_count != null ? [1] : []

                    content {
                      min = override.value.instance_requirements.vcpu_count.min
                      max = override.value.instance_requirements.vcpu_count.max
                    }
                  }
                }
              }
            }
          }
        }
      }

    }
  }

  dynamic "tag" {
    for_each = var.ecs_managed ? [1] : []

    content {
      key                 = "AmazonECSManaged"
      value               = true
      propagate_at_launch = true
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-asg"
    propagate_at_launch = true
  }

  lifecycle {
    precondition {
      condition     = !(var.instance_distribution != null && var.mixed_policies_launch_template == null)
      error_message = "Variable `mixed_policies_launch_template` must be defined if variable `instance_distribution` is defined"
    }
  }

}
