variable "name_prefix" {
  type        = string
  description = "Prefix for naming or tagging resources"
}

variable "region" {
  type        = string
  description = "AWS region to deploy resources into"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of AWS resource IDs for subnets to provision instances in"
}

variable "placement_strategy" {
  type        = string
  description = "Placement strategy for the ASG instances. Must be one of cluster, partition, or spread"
  default     = "spread"

  validation {
    condition     = contains(["cluster", "partition", "spread"], var.placement_strategy)
    error_message = "Variable `placement_strategy` must be one of cluster, partition, or spread"
  }
}

variable "max_size" {
  type        = number
  description = "Max number of instances for the ASG"
  default     = 5
}

variable "min_size" {
  type        = number
  description = "Min number of instances for the ASG"
  default     = 1
}

variable "desired_capacity" {
  type        = number
  description = "Desired number of instances for the ASG"
  default     = 1
}

variable "target_group_arns" {
  type    = list(string)
  default = null
}

variable "health_check_grace_period" {
  type    = number
  default = 300
}

variable "health_check_type" {
  type    = string
  default = "EC2"

  validation {
    condition     = contains(["EC2", "ELB"], var.health_check_type)
    error_message = "Variable `health_check_type` must be one of EC2 or ELB"
  }
}

variable "force_delete" {
  type    = bool
  default = false
}

variable "launch_template_id" {
  type        = string
  description = "Launch template for the EC2 instances"
}

variable "service_linked_role_arn" {
  type        = string
  description = "AWS resource ARN for the service role to be linked to the ASG"
  default     = null
}

variable "enabled_metrics" {
  type        = list(string)
  description = "List of strings specifying the metrics to enable"
  default     = []
}

variable "instance_distribution" {
  type = object({
    on_demand_allocation_strategy            = optional(string)
    on_demand_base_capacity                  = optional(number)
    on_demand_percentage_above_base_capacity = optional(number)
    spot_allocation_strategy                 = optional(string)
    spot_instance_pools                      = optional(number)
    spot_max_price                           = optional(number)
  })
  description = "On demand and spot instance distribution settings for mixed policies"
  default     = null
}

variable "mixed_policies_launch_template" {
  type = object({
    launch_template_specification = object({
      launch_template_id = string
      version            = string
    })
    overrides = optional(list(object({
      instance_type = optional(string)
      instance_requirements = optional(object({
        accelerator_count = optional(object({
          min = optional(number)
          max = optional(number)
        }))
        accelerator_manufacturers = optional(list(string))
        accelerator_names         = optional(list(string))
        accelerator_total_memory_mib = optional(object({
          min = optional(number)
          max = optional(number)
        }))
        accelerator_types      = optional(list(string))
        allowed_instance_types = optional(list(string))
        bare_metal             = optional(string)
        baseline_ebs_bandwidth_mbps = optional(object({
          min = optional(number)
          max = optional(number)
        }))
        burstable_performance   = optional(string)
        cpu_manufacturers       = optional(list(string))
        excluded_instance_types = optional(list(string))
        instance_generations    = optional(list(string))
        local_storage           = optional(string)
        local_storage_types     = optional(list(string))
        memory_gib_per_vcpu = optional(object({
          min = optional(number)
          max = optional(number)
        }))
        memory_mib = optional(object({
          min = number
          max = optional(number)
        }))
        network_bandwidth_gbps = optional(object({
          min = optional(number)
          max = optional(number)
        }))
        network_interface_count = optional(object({
          min = optional(number)
          max = optional(number)
        }))
        on_demand_max_price_percentage_over_lowest_price = optional(number)
        require_hibernate_support                        = optional(bool)
        spot_max_price_percentage_over_lowest_price      = optional(number)
        total_local_storage_gb = optional(object({
          min = optional(number)
          max = optional(number)
        }))
        vcpu_count = optional(object({
          min = number
          max = optional(number)
        }))
      }))
      launch_template_specification = optional(object({
        launch_template_id = string
        version            = optional(string)
      }))
      weighted_capacity = optional(number)
    })))
  })
  description = "Launch template for mixed policies"
  default     = null

  # validation {
  #   condition     = alltrue([for override in var.mixed_policies_launch_template.overrides : override != null && override.instance_requirements != null && alltrue([for accelerator_manufacturer in override.instance_requirements.accelerator_manufacturers : contains(["amazon-web-services", "amd", "nvidia", "xilinx"], accelerator_manufacturer)])])
  #   error_message = "Variable `mixed_policies_launch_template.override.accelerator_manufacturers` must be one of amazon-web-services, amd, nvidia, or xilinx"
  # }

  # validation {
  #   condition     = alltrue([for override in var.mixed_policies_launch_template.overrides : override != null && override.instance_requirements != null && alltrue([for accelerator_name in override.instance_requirements.accelerator_names : contains(["a100", "v100", "k80", "t4", "m60", "radeon-pro-v520", "vu9p"], accelerator_name)])])
  #   error_message = "Variable `mixed_policies_launch_template.override.accelerator_names` can only have elements that are one of a100, v100, k80, t4, m60, radeon-pro-v520, or vu9p"
  # }

  # validation {
  #   condition     = alltrue([for override in var.mixed_policies_launch_template.overrides : override != null && override.instance_requirements != null && alltrue([for accelerator_type in override.instance_requirements.accelerator_types : contains(["fpga", "gpu", "inference"], accelerator_type)])])
  #   error_message = "Variable `mixed_policies_launch_template.override.accelerator_types` can only have elements that are one of fpga, gpu, or inference"
  # }

  // TODO: Add validation for the rest of the fields
}

variable "ecs_managed" {
  type        = bool
  description = "Specify whether or not the ASG will be linked to an ECS"
  default     = false
}

variable "additional_attachments" {
  type        = bool
  description = "Specify whether or not the ASG will have additional `aws_autoscaling_attachment` resource blocks associated with it"
  default     = false
}
