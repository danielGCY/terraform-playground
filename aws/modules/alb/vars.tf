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

### ALB
variable "alb_use_name_prefix" {
  type        = bool
  description = "Specify whether to use `name_prefix` or `name` when naming the ALB"
  default     = false
}

variable "alb_name" {
  type    = string
  default = null
}

variable "alb_name_prefix" {
  type    = string
  default = null

  validation {
    condition     = var.alb_name_prefix == null ? true : length(var.alb_name_prefix) <= 6
    error_message = "Variable `alb_name_prefix` must not be longer than 6 characters"
  }
}

variable "alb_access_logs" {
  type = object({
    bucket  = string
    enabled = optional(bool)
    prefix  = optional(string)
  })
  description = "Access logs configuration block for ALB"
  default     = null
}

variable "alb_customer_owned_ipv4_pool" {
  type        = string
  description = "ID of the customer owned ipv4 pool to use for this load balancer"
  default     = null
}

variable "alb_desync_mitigation_mode" {
  type        = string
  description = "Determines how the load balancer handles requests that might pose a security risk to an application due to HTTP desync. Valid values are \"monitor\", \"defensive\", and \"strictest\""
  default     = "defensive"

  validation {
    condition     = contains(["monitor", "defensive", "strictest"], var.alb_desync_mitigation_mode)
    error_message = "Variable `alb_desync_mitigation_mode` must be one of \"monitor\", \"defensive\", or \"strictest\""
  }
}

variable "alb_drop_invalid_header_fields" {
  type        = bool
  description = "Indicates whether HTTP headers with header fields that are not valid are removed by the laod balancer (`true`) or routed to targets (`false`)"
  default     = false
}

variable "alb_enable_deletion_protection" {
  type        = bool
  description = "If true, deletion of the load balancer will be disabled by the AWS API"
  default     = false
}

variable "alb_enable_http2" {
  type        = bool
  description = "Indicates whether HTTP/2 is enabled"
  default     = true
}

variable "alb_enable_tls_version_and_cipher_suite_headers" {
  type        = bool
  description = "Indicates whether the two headers (`x-amzn-tls-version` and `x-amzn-tls-cipher-suite`), which contain information about the negotiated TLS version and cipher suite, are added to the client request before sending it to the target"
  default     = false
}

variable "alb_enable_xff_client_port" {
  type        = bool
  description = "Indicates whether the X-Forwarded-For header should preserve the source port that the client used to connect to the load balancer"
  default     = false
}

variable "alb_enable_waf_fail_open" {
  type        = bool
  description = "Indicates whether to allow a WAF-enabled load balancer to route requests to targets if it is unable to forward the request to AWS WAF"
  default     = false
}

variable "alb_idle_timeout" {
  type        = number
  description = "The time in seconds that the connection is allow to be idle"
  default     = 60
}

variable "alb_internal" {
  type        = bool
  description = "Specify whether the LB should be internal only"
  default     = false
}

variable "alb_ip_address_type" {
  type        = string
  description = "The type of IP addresses used by the subnets for your load balancer. Valid values are \"ipv4\" and \"dualstack\""
  default     = "ipv4"
}

variable "alb_security_groups" {
  type        = list(string)
  description = "List of security group IDs assign to the LB"
  default     = []
}

variable "alb_preserve_host_header" {
  type        = bool
  description = "Indicates whether the ALB should preserve the Host header in the HTTP request and send it to the target without any change"
  default     = false
}

variable "alb_subnet_mappings" {
  type = list(object({
    subnet_id            = string
    allocation_id        = optional(string)
    ipv6_address         = optional(string)
    private_ipv4_address = optional(string)
  }))
  description = "Subnet mapping configuration blocks"
  default     = []

  validation {
    condition     = alltrue([for mapping in var.alb_subnet_mappings : mapping.allocation_id != null || mapping.ipv6_address != null || mapping.private_ipv4_address != null])
    error_message = "One of `allocation_id`, `ipv6_address` or `private_ipv4_address` must be set for each mapping block"
  }
}

variable "alb_subnets" {
  type        = list(string)
  description = "List of subnet IDs to attach to the ALB. If `alb_subnet_mappings` is specified, this variable will be ignored"
  default     = []
}

variable "alb_xff_header_processing_mode" {
  type        = string
  description = "Determines how the load balancer modifies the `X-Forwarded-For` header in the HTTP request before sending the request to the target. Valid values are \"append\", \"preserve\", and \"remove\""
  default     = "append"
}

variable "alb_tags" {
  type        = map(string)
  description = "Tags to be applied to the ALB"
  default     = null
}
