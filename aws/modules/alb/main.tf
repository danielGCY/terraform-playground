locals {
  alb_name        = var.alb_use_name_prefix ? null : coalesce(var.alb_name, "${var.name_prefix}-alb-main")
  alb_name_prefix = var.alb_use_name_prefix ? coalesce(var.alb_name_prefix, "alb") : null
  alb_subnets     = length(var.alb_subnet_mappings) > 0 ? null : var.alb_subnets
  alb_tags        = merge(var.global_tags, var.alb_tags)
}

resource "aws_lb" "main" {
  name                                        = var.alb_use_name_prefix ? null : local.alb_name
  name_prefix                                 = var.alb_use_name_prefix ? local.alb_name : null
  load_balancer_type                          = "application"
  customer_owned_ipv4_pool                    = var.alb_customer_owned_ipv4_pool
  desync_mitigation_mode                      = var.alb_desync_mitigation_mode
  enable_cross_zone_load_balancing            = true
  drop_invalid_header_fields                  = var.alb_drop_invalid_header_fields
  enable_deletion_protection                  = var.alb_enable_deletion_protection
  enable_http2                                = var.alb_enable_http2
  enable_tls_version_and_cipher_suite_headers = var.alb_enable_tls_version_and_cipher_suite_headers
  enable_xff_client_port                      = var.alb_enable_xff_client_port
  enable_waf_fail_open                        = var.alb_enable_waf_fail_open
  idle_timeout                                = var.alb_idle_timeout
  internal                                    = var.alb_internal
  ip_address_type                             = var.alb_ip_address_type
  security_groups                             = var.alb_security_groups
  preserve_host_header                        = var.alb_preserve_host_header
  subnets                                     = local.alb_subnets
  xff_header_processing_mode                  = var.alb_xff_header_processing_mode

  dynamic "access_logs" {
    for_each = var.alb_access_logs != null ? [var.alb_access_logs] : []

    content {
      bucket  = access_logs.value["bucket"]
      enabled = access_logs.value["enabled"]
      prefix  = access_logs.value["prefix"]
    }
  }

  dynamic "subnet_mapping" {
    for_each = var.alb_subnet_mappings

    content {
      subnet_id            = subnet_mapping.value["subnet_id"]
      allocation_id        = subnet_mapping.value["allocation_id"]
      ipv6_address         = subnet_mapping.value["ipv6_address"]
      private_ipv4_address = subnet_mapping.value["private_ipv4_address"]
    }
  }

  tags = local.alb_tags

  lifecycle {
    precondition {
      condition     = alltrue([for mapping in var.alb_subnet_mappings : var.alb_internal ? mapping.private_ipv4_address != null : true])
      error_message = "`private_ipv4_address` must be specified in `alb_subnet_mappings` if `alb_internal` is set to `true`"
    }
  }
}
