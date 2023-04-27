variable "name_prefix" {
  type        = string
  description = "Prefix to tag resources provisioned"
}

variable "region" {
  type        = string
  description = "AWS region to provision resources in"
}

variable "global_tags" {
  type        = map(string)
  description = "Tags to be applied to all the provisioned resources"
  default     = null
}

variable "create_ecr" {
  type        = bool
  description = "Whether to create an ECR"
  default     = true
}

variable "ecr_name" {
  type        = string
  description = "The name for the ECR"
  default     = null
}

variable "ecr_tags" {
  type    = map(string)
  default = null
}

variable "force_delete" {
  type        = bool
  description = "Whether to enable the deletion of ECR when there's images"
  default     = false
}

variable "vpc_id" {
  type        = string
  description = "AWS resource ID for the VPC"
}

variable "asg_arn" {
  type        = string
  description = "AWS resource ARN for the ASG"
  default     = null
}

variable "ecs_cluster_name" {
  type    = string
  default = null
}

variable "ecs_provider" {
  type        = string
  description = "The desired provider for the ECS cluster. Must be one of 'EC2' or 'FARGATE'"

  validation {
    condition     = contains(["EC2", "FARGATE"], var.ecs_provider)
    error_message = "Variable `ecs_provider` must be one of EC2 or FARGATE"
  }
}

variable "ecs_cluster_log_configuration" {
  type = object({
    cloud_watch_encryption_enabled = optional(bool)
    cloud_watch_log_group_name     = optional(string)
    s3_bucket_name                 = optional(string)
    s3_bucket_encryption_enabled   = optional(bool)
    s3_key_prefix                  = optional(string)
  })
  description = "Log configuration for the provisioned ECS cluster"
  default     = null
}

variable "ecs_cluster_kms_key_id" {
  type        = string
  description = "KMS key ID to specify the key used to encrypt the data between local client and the container"
  default     = null
}

variable "ecs_cluster_tags" {
  type    = map(string)
  default = null
}

### TASK DEFINITION
variable "task_definition_family" {
  type        = string
  description = "Name for the task definition"
  default     = null
}

variable "reference_created_ecr" {
  type        = bool
  description = "Specify whether the image to be deployed is contained in the ECR that will be provisioned. Note that if `image` property exists in a container definition, it will not be overwritten"
  default     = true
}

variable "image_tag" {
  type        = string
  description = "The tag of the image to be referenced. Only used if `reference_created_ecr` is `true`"
  default     = "latest"
}

variable "task_definition_container_definitions" {
  type        = string
  description = "JSON string representation for the container definitions"
}

variable "task_definition_network_mode" {
  type        = string
  description = "Docker networking mode to use for the containers in the task"
  default     = "awsvpc"

  validation {
    condition     = contains(["none", "bridge", "awsvpc", "host"], var.task_definition_network_mode)
    error_message = "Variable `task_definition_network_mode` must be one of \"none\", \"bridge\", \"awsvpc\", or \"host\""
  }
}

variable "task_definition_cpu" {
  type        = number
  description = "Number of cpu units used by the task. Must be provided if `task_definition_required_capabilities` is \"FARGATE\""
  default     = null
}

variable "task_definition_memory" {
  type        = number
  description = "Amount of memory (MiB) used by the task. Must be provided if `task_definition_required_capabilities` is \"FARGATE\""
  default     = null
}

variable "task_definition_required_compatibilities" {
  type        = string
  description = "Launch type required by the task. Must be one of \"EC2\" or \"FARGATE\""
  default     = "EC2"

  validation {
    condition     = contains(["EC2", "FARGATE"], var.task_definition_required_compatibilities)
    error_message = "Variable `task_definition_required_compatibilities` must be one of \"EC2\" or \"FARGATE\""
  }
}

variable "task_definition_execution_role_arn" {
  type        = string
  description = "ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume"
  default     = null
}

variable "task_definition_ipc_mode" {
  type        = string
  description = "IPC resource namespace to be used for the containers in the task"
  default     = null

  validation {
    condition     = var.task_definition_ipc_mode == null ? true : contains(["host", "task", "none"], var.task_definition_ipc_mode)
    error_message = "Variable `task_definition_ipc_mode` must be one of \"host\", \"task\" or \"none\""
  }
}

variable "task_definition_pid_mode" {
  type        = string
  description = "Process namespace to use for the containers in the task"
  default     = null

  validation {
    condition     = var.task_definition_pid_mode == null ? true : contains(["host", "task"], var.task_definition_pid_mode)
    error_message = "Variable `task_definition_pid_mode` must be one of \"host\" or \"task\""
  }
}

variable "task_definition_skip_destroy" {
  type        = bool
  description = "Whether to retain the old revision when the resource is destroyed or replacement is necessary"
  default     = false
}

variable "task_definition_task_role_arn" {
  type        = string
  description = "ARN of IAM role that allows ECS container task to make calls to other AWS services"
  default     = null
}

variable "task_definition_volume" {
  type = object({
    name      = string
    host_path = optional(string)
  })
  default = null
}

variable "task_definition_placement_constraints" {
  type = list(object({
    expression = optional(string)
    type       = string
  }))
  description = "Placement constraint rules that are taken into consideration during task placement"
  default     = null

  validation {
    condition     = var.task_definition_placement_constraints == null ? true : length(var.task_definition_placement_constraints) <= 10
    error_message = "Variable `task_definition_placement_constraints` must contain 10 or less constraints"
  }
}

variable "task_definition_tags" {
  type    = map(string)
  default = null
}

### ECS SERVICE
variable "service_name" {
  type        = string
  description = "Name for the ECS service"
  default     = null
}

variable "service_alarms" {
  type = object({
    alarm_names = list(string)
    enable      = bool
    roolback    = bool
  })
  description = "Cloudwatch alarms"
  default     = null
}

variable "desired_instance_count" {
  type        = number
  description = "Desired number of instances for the ECS service"
  default     = 1
}

variable "enable_ecs_managed_tags" {
  type        = bool
  description = "Specifies whether to enable Amazon ECS managed tags for the tasks within the service"
  default     = null
}

variable "enable_execute_command" {
  type        = bool
  description = "Specifies whether to enable Amazon ECS Exec fo rthe tasks within the service"
  default     = null
}

variable "force_new_deployment" {
  type        = bool
  description = "Enable to force a new taks deployment of the same service"
  default     = null
}

variable "health_check_grace_period_seconds" {
  type        = number
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks"
  default     = null
}

variable "service_iam_role" {
  type        = string
  description = "ARN of the IAM role that allows Amazon ECS to make calls to your load balancer on your behalf. Only required when using a load balancer and your task definition does not use the `awsvpc` network mode"
  default     = null
}

variable "service_launch_type" {
  type        = string
  description = "Launch type on which to run the service"
  default     = "EC2"

  validation {
    condition     = contains(["EC2", "FARGATE", "EXTERNAL"], var.service_launch_type)
    error_message = "Variable `service_launch_type` must be one of \"EC2\", \"FARGATE\", or \"EXTERNAL\""
  }
}

variable "service_load_balancer" {
  type = object({
    elb_name         = optional(string)
    target_group_arn = optional(string)
    container_name   = string
    container_port   = number
  })
  description = "Load balancer config. Specify `elb_name` if using a classic ELB, otherwise, use `target_group_arn`"
  default     = null
}

variable "service_network_configuration" {
  type = object({
    subnets          = list(string)
    security_groups  = optional(list(string))
    assign_public_ip = optional(bool)
  })
  description = "Network configuration for the service. Must be specified if `task_definition_network_mode` is \"awsvpc\""
  default     = null
}

variable "service_ordered_placement_strategies" {
  type = list(object({
    type  = string
    field = optional(string)
  }))
  description = "Service level strategy rules that are taken into consideration during task placement"
  default     = null

  validation {
    condition     = var.service_ordered_placement_strategies == null ? true : length(var.service_ordered_placement_strategies) <= 5
    error_message = "Variable `service_ordered_placement_strategies` must contain 5 or less strategies"
  }
}

variable "service_placement_constraints" {
  type = list(object({
    expression = optional(string)
    type       = string
  }))
  description = "Placement constraint rules that are taken into consideration during task placement"
  default     = null

  validation {
    condition     = var.service_placement_constraints == null ? true : length(var.service_placement_constraints) <= 10
    error_message = "Variable `service_placement_constraints` must contain 10 or less constraints"
  }
}

variable "service_platform_version" {
  type        = string
  description = "Platform version to run the service. Only applicable for \"FARGATE\" `service_launch_type`"
  default     = "LATEST"
}

variable "service_propagate_tags" {
  type        = string
  description = "Specifies whether to propogate the tags from the task definition or the service to the tasks"
  default     = null

  validation {
    condition     = var.service_propagate_tags == null ? true : contains(["SERVICE", "TASK_DEFINITION"], var.service_propagate_tags)
    error_message = "Variable `service_propagate_tags` must be one of \"SERVICE\" or \"TASK_DEFINITION\""
  }
}

variable "service_scheduling_strategy" {
  type        = string
  description = "Scheduling strategy to use for the service. Valid values are \"REPLICA\" and \"DAEMON\". Tasks using \"FARGATE\" launch type or \"CODE_DEPLOY\" or \"EXTERNAL\" deployment controller types don't support the \"DAEMON\" scheduling strategy"
  default     = "REPLICA"

  validation {
    condition     = contains(["REPLICA", "DAEMON"], var.service_scheduling_strategy)
    error_message = "Variable `service_scheduling_strategy` must be one of \"REPLICA\" or \"DAEMON\""
  }
}

variable "service_registries" {
  type = object({
    registry_arn = string
    port         = optional(number)
  })
  description = "Service discovery registries for the service"
  default     = null
}

variable "service_triggers" {
  type        = map(string)
  description = "Map of arbitrary keys and values that, when changed, will trigger an in-place update (or redeployment)"
  default     = null
}

variable "service_wait_for_steady_state" {
  type        = bool
  description = "If `true`, Terraform will wai for the service to reach a steady state before continuing"
  default     = false
}

variable "service_tags" {
  type    = map(string)
  default = null
}
