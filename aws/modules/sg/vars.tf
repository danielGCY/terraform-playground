variable "region" {
  type        = string
  description = "AWS region to deploy resources into"
}

variable "use_name_prefix" {
  type    = bool
  default = false
}

variable "name" {
  type    = string
  default = "default"
}

variable "name_prefix" {
  type    = string
  default = "default"
}

variable "description" {
  type    = string
  default = null
}

variable "vpc_id" {
  type    = string
  default = null
}

variable "revoke_rules_on_delete" {
  type    = bool
  default = false
}

variable "ingress_rules" {
  type = list(object({
    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    description                  = optional(string)
    from_port                    = optional(number)
    to_port                      = optional(number)
    ip_protocol                  = string
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
  }))
  description = "Ingress rules"
  default = [{
    cidr_ipv4   = "0.0.0.0/0"
    description = "Allow all inbound connections"
    ip_protocol = "ALL"
  }]

  validation {
    condition     = alltrue([for rule in var.ingress_rules : sum([rule.cidr_ipv4 != null ? 1 : 0, rule.cidr_ipv6 != null ? 1 : 0, rule.prefix_list_id != null ? 1 : 0, rule.referenced_security_group_id != null ? 1 : 0]) == 1])
    error_message = "Must only specify one of `cidr_ipv4`, `cidr_ipv6`, `prefix_list_id`, or `referenced_security_group_id` for `ingress_rules`"
  }

  validation {
    condition     = alltrue([for rule in var.ingress_rules : contains(["ALL", "TCP", "UDP", "ICMP", "ICMPV6"], upper(rule.ip_protocol))])
    error_message = "`ip_protocol` must be one of 'ALL', 'TCP', 'UDP', 'ICMP', 'ICMPV6'"
  }
}

variable "egress_rules" {
  type = list(object({
    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    description                  = optional(string)
    from_port                    = optional(number)
    to_port                      = optional(number)
    ip_protocol                  = string
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
  }))
  description = "Ingress rules"
  default = [{
    cidr_ipv4   = "0.0.0.0/0"
    description = "Allow all outbound connections"
    ip_protocol = "ALL"
  }]

  validation {
    condition     = alltrue([for rule in var.egress_rules : sum([rule.cidr_ipv4 != null ? 1 : 0, rule.cidr_ipv6 != null ? 1 : 0, rule.prefix_list_id != null ? 1 : 0, rule.referenced_security_group_id != null ? 1 : 0]) == 1])
    error_message = "Must only specify one of `cidr_ipv4`, `cidr_ipv6`, `prefix_list_id`, or `referenced_security_group_id` for `egress_rules`"
  }

  validation {
    condition     = alltrue([for rule in var.egress_rules : contains(["ALL", "TCP", "UDP", "ICMP", "ICMPV6"], upper(rule.ip_protocol))])
    error_message = "`ip_protocol` must be one of 'ALL', 'TCP', 'UDP', 'ICMP', 'ICMPV6'"
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags for security group"
  default     = null
}
