variable "prefix" {
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

variable "alb_id" {
  type        = string
  description = "AWS resource ID for the ALB to be associated with the target group and listener"
}

### TARGET GROUP
variable "target_type" {
  type        = string
  description = "The type of target to be created. Valid values are \"lambda\", \"instance\", and \"ip\""

  validation {
    condition     = contains(["lambda", "instance", "ip"], var.target_type)
    error_message = "Variable `target_type` must be one of \"lambda\", \"instance\", \"ip\""
  }
}

variable "vpc_id" {
  type    = string
  default = null
}

variable "use_name_prefix" {
  type    = bool
  default = false
}

variable "name" {
  type    = string
  default = null
}

variable "name_prefix" {
  type    = string
  default = null

  validation {
    condition     = var.name_prefix == null ? true : length(var.name_prefix) <= 6
    error_message = "Variable `name_prefix` must not be longer than 6 characters"
  }
}

variable "deregistration_delay" {
  type        = number
  description = "Amount of time for ALB to wait before changing the state of a deregistering target from draining to unused"
  default     = 300

  validation {
    condition     = var.deregistration_delay >= 0 && var.deregistration_delay <= 3600
    error_message = "Variable `deregistration_delay` must be between 0 and 3600"
  }
}

variable "health_check" {
  type = object({
    enabled             = optional(bool)
    healthy_threshold   = optional(number)
    interval            = optional(number)
    matcher             = optional(string)
    path                = optional(string)
    port                = optional(number)
    protocol            = optional(string)
    timeout             = optional(number)
    unhealthy_threshold = optional(number)
  })
  description = "Health Check configuration block"
  default = {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    matcher             = "200"
    path                = "/"
    protocol            = "HTTP"
    timeout             = 10
    unhealthy_threshold = 3
  }

  validation {
    condition     = coalesce(var.health_check.healthy_threshold, 3) <= 10 && coalesce(var.health_check.healthy_threshold, 3) >= 2
    error_message = "Variable `health_check.healthy_threshold` must be a number in the range of 2-10"
  }

  validation {
    condition     = coalesce(var.health_check.interval, 30) <= 300 && coalesce(var.health_check.interval, 30) >= 5
    error_message = "Variable `health_check.interval` must be a number in the range of 5-300"
  }

  validation {
    condition     = contains(["TCP", "HTTP", "HTTPS"], var.health_check.protocol)
    error_message = "Variable `health_check.protocol` must be one of \"TCP\", \"HTTP\", or \"HTTPS\""
  }

  validation {
    condition     = coalesce(var.health_check.unhealthy_threshold, 3) <= 10 && coalesce(var.health_check.unhealthy_threshold, 3) >= 2
    error_message = "Variable `health_check.unhealthy_threshold` must be a number in the range of 2-10"
  }
}

variable "load_balancing_cross_zone_enabled" {
  type        = string
  description = "Indicates whether cross zone load balancing is enabled. Valid values are \"true\", \"false\", or \"use_load_balancer_configuration\""
  default     = "use_load_balancer_configuration"

  validation {
    condition     = var.load_balancing_cross_zone_enabled == null ? true : contains(["use_load_balancer_configuration", "true", "false"], var.load_balancing_cross_zone_enabled)
    error_message = "Variable `load_balancing_cross_zone_enabled` must be one of \"use_load_balancer_configuration\", \"true\", or \"false\""
  }
}

variable "slow_start" {
  type        = number
  description = "Amount of time (s) for targets to warm up before the load balanacer sends them a full share of requests"
  default     = 0

  validation {
    condition     = var.slow_start == 0 ? true : var.slow_start >= 30 && var.slow_start <= 900
    error_message = "Variable `slow_start` must be either 0 or a value between the range 30-900 inclusive"
  }
}

variable "stickiness" {
  type = object({
    cookie_duration = optional(number)
    cookie_name     = optional(string)
    enabled         = optional(bool)
    type            = optional(string)
  })
  description = "Stickiness configuration block"
  default = {
    enabled         = true
    type            = "lb_cookie"
    cookie_duration = 86400
  }

  validation {
    condition     = contains(["lb_cookie", "app_cookie"], coalesce(var.stickiness.type, "lb_cookie"))
    error_message = "Variable `stickiness.type` must be one of \"lb_cookie\" or \"app_cookie\""
  }

  validation {
    condition     = var.stickiness.type == "app_cookie" ? var.stickiness.cookie_name != null : true
    error_message = "Variable `stickiness.cookie_name` must be specified when `stickiness.type` is \"app_cookie\""
  }
}

variable "tg_tags" {
  type        = map(string)
  description = "Tags to be applied to all of the target groups (e.g. `tg_lambdas`, `tg_instances`, `tg_ips`)"
  default     = null
}

### LAMBDA TARGET TYPE SPECIFIC CONFIG
variable "lambda_multi_value_headers_enabled" {
  type        = bool
  description = "Whether the request and response headers exchanged between the load balancer and the Lambda function include arrays of values or strings"
  default     = false
}

### INSTANCE/IPs TARGET TYPE SPECIFIC CONFIG
variable "port" {
  type        = number
  description = "Port on which targets receive traffic"
  default     = null
}

variable "protocol" {
  type        = string
  description = "Protocol to use for routing traffic to the targets. Valid values are \"GENEVE\", \"HTTP\", \"HTTPS\", \"TCP\", \"TCP_UDP\", \"TLS\", and \"UDP\""
  default     = null
}

variable "protocol_version" {
  type        = string
  description = "Protocol version, only applicable when `protocol` is \"HTTP\" or \"HTTPS\""
  default     = null

  validation {
    condition     = var.protocol_version == null ? true : contains(["HTTP1", "HTTP2", "GRPC"], var.protocol_version)
    error_message = "Variable `protocol_version` must be one of \"HTTP1\", \"HTTP2\", or \"GRPC\""
  }
}

### LISTENER
variable "default_action_type" {
  type        = string
  description = "Type of routing action that the listener should take"

  validation {
    condition     = contains(["forward", "redirect", "fixed-response"], var.default_action_type)
    error_message = "Variable `default_action_type` must be one of \"forward\", \"redirect\", or \"fixed-response\""
  }
}

variable "listener_protocol" {
  type        = string
  description = "Protocol for connections from clients to the ALB. Valid values are \"HTTP\" and \"HTTPS\""
  default     = "HTTP"

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.listener_protocol)
    error_message = "Variable `listener_protocol` must be either \"HTTP\" or \"HTTPS\""
  }
}

variable "listener_port" {
  type        = number
  description = "Port on which teh load balancer is listening"
  default     = null
}

variable "listener_certificate_arn" {
  type        = string
  description = "ARN of the default SSL server certificate. Exactly one certificate is required if the protocol is HTTPS"
  default     = null
}

variable "listener_ssl_policy" {
  type        = string
  description = "Name of the SSL Policy for the listener. Required if `listener_protocol` is \"HTTPS\""
  default     = null
}

variable "default_action_forward" {
  type = object({
    target_groups = list(object({
      arn    = optional(string)
      weight = optional(number)
    }))
    stickiness = optional(object({
      duration = number
      enabled  = optional(bool)
    }))
  })
  description = "Configuration block for creating an action that distributes requests among one or more target groups"
  default     = null

  validation {
    condition     = var.default_action_forward == null ? true : alltrue([for group in var.default_action_forward.target_groups : group.weight == null ? true : group.weight >= 0 && group.weight <= 999])
    error_message = "Variable `default_action_forward.target_groups.weight` must be between 0 and 999"
  }
}

variable "default_action_redirect" {
  type = object({
    status_code = string
    host        = optional(string)
    path        = optional(string)
    port        = optional(string)
    protocol    = optional(string)
    query       = optional(string)
  })
  description = "Configuration block for creating a redirect action"
  default     = null

  validation {
    condition     = var.default_action_redirect == null ? true : contains(["HTTP_301", "HTTP_302"], var.default_action_redirect.status_code)
    error_message = "Variable `default_action_redirect.status_code` must be either \"HTTP_301\" or \"HTTP_302\""
  }
}

variable "default_action_fixed_response" {
  type = object({
    content_type = string
    message_body = optional(string)
    status_code  = optional(string)
  })
  description = "Information for creating an action that returns a custom HTTP response"
  default     = null

  validation {
    condition     = var.default_action_fixed_response == null ? true : contains(["text/plain", "text/css", "text/html", "application/javascript", "application/json"], var.default_action_fixed_response.content_type)
    error_message = "Variable `default_action_fixed_response.content_type` must be one of \"text/plain\", \"text/css\", \"text/html\", \"application/javascript\", or \"application/json\""
  }

  validation {
    condition     = var.default_action_fixed_response == null ? true : contains(["2", "3", "4"], substr(coalesce(var.default_action_fixed_response.status_code, "200")))
    error_message = "Variable `default_action_fixed_response.status_code` must be one of \"2XX\", \"3XX\", or \"4XX\""
  }
}

variable "listener_tags" {
  type        = map(string)
  description = "Tags to be applied to the listener only"
  default     = null
}
