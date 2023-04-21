variable "name_prefix" {
  type        = string
  description = "Prefix to tag resources provisioned"
}

variable "region" {
  type        = string
  description = "AWS region to provision resources in"
}

variable "vpc_id" {
  type        = string
  description = "AWS resource ID for the VPC"
}

variable "asg_arn" {
  type        = string
  description = "AWS resource ARN for the ASG"
}

variable "cluster_name" {
  type    = string
  default = "default"
}

variable "ecs_provider" {
  type        = string
  description = "The desired provider for the ECS cluster. Must be one of 'EC2' or 'FARGATE'"

  validation {
    condition     = contains(["EC2", "FARGATE"], var.ecs_provider)
    error_message = "Variable `ecs_provider` must be one of EC2 or FARGATE"
  }
}

variable "log_configuration" {
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

variable "kms_key_id" {
  type        = string
  description = "KMS key ID to specify the key used to encrypt the data between local client and the container"
  default     = null
}
