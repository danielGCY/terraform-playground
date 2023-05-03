resource "aws_lb_target_group" "main" {
  name                               = var.use_name_prefix ? null : coalesce(var.name, "${var.prefix}-tg")
  name_prefix                        = var.use_name_prefix ? coalesce(var.name_prefix, "tg") : null
  target_type                        = var.target_type
  vpc_id                             = var.vpc_id
  port                               = var.port
  protocol                           = var.protocol
  protocol_version                   = var.protocol_version
  lambda_multi_value_headers_enabled = var.lambda_multi_value_headers_enabled
  deregistration_delay               = var.deregistration_delay
  load_balancing_cross_zone_enabled  = var.load_balancing_cross_zone_enabled
  slow_start                         = var.slow_start

  health_check {
    enabled             = var.health_check.enabled
    healthy_threshold   = var.health_check.healthy_threshold
    interval            = var.health_check.interval
    matcher             = var.health_check.matcher
    path                = var.health_check.path
    port                = var.health_check.port
    protocol            = var.health_check.protocol
    timeout             = var.health_check.timeout
    unhealthy_threshold = var.health_check.unhealthy_threshold
  }

  stickiness {
    enabled         = var.stickiness.enabled
    type            = var.stickiness.type
    cookie_duration = var.stickiness.cookie_duration
    cookie_name     = var.stickiness.cookie_name
  }

  tags = merge(var.global_tags, var.tg_tags)

  lifecycle {
    precondition {
      condition     = contains(["instance", "ip"], var.target_type) ? var.port != null : true
      error_message = "Variable `port` must be specified when `target_type` is ${var.target_type}"
    }

    precondition {
      condition     = contains(["instance", "ip"], var.target_type) ? var.protocol != null : true
      error_message = "Variable `protocol` must be specified when `target_type` is ${var.target_type}"
    }
  }
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = var.alb_id
  protocol          = var.listener_protocol
  certificate_arn   = var.listener_certificate_arn
  port              = var.listener_port
  ssl_policy        = var.listener_ssl_policy

  default_action {
    type = var.default_action_type

    dynamic "forward" {
      for_each = var.default_action_type == "forward" ? [var.default_action_forward] : []

      content {
        dynamic "target_group" {
          for_each = forward.value.target_groups

          content {
            arn    = coalesce(target_group.value["arn"], aws_lb_target_group.main.arn)
            weight = target_group.value["weight"]
          }
        }

        dynamic "stickiness" {
          for_each = forward.value.stickiness != null ? [forward.value.stickiness] : []

          content {
            duration = stickiness.value.duration
            enabled  = stickiness.value.enabled
          }
        }
      }
    }

    dynamic "redirect" {
      for_each = var.default_action_type == "redirect" ? [var.default_action_redirect] : []

      content {
        status_code = redirect.value.status_code
        host        = redirect.value.host
        path        = redirect.value.path
        port        = redirect.value.port
        protocol    = redirect.value.protocol
        query       = redirect.value.query
      }
    }

    dynamic "fixed_response" {
      for_each = var.default_action_type == "fixed-response" ? [var.default_action_fixed_response] : []

      content {
        content_type = fixed_response.value.content_type
        message_body = fixed_response.value.message_body
        status_code  = fixed_response.value.status_code
      }
    }
  }

  tags = merge(var.global_tags, var.listener_tags)

  lifecycle {
    precondition {
      condition     = sum([var.default_action_forward != null ? 1 : 0, var.default_action_redirect != null ? 1 : 0, var.default_action_fixed_response != null ? 1 : 0]) == 1
      error_message = "Must only specify one of `default_action_forward`, `default_action_redirect`, or `default_action_fixed_response`"
    }

    precondition {
      condition     = var.default_action_type == "forward" ? var.default_action_forward != null : true
      error_message = "Must specify `default_action_forward` if `default_action_type` is \"forward\""
    }

    precondition {
      condition     = var.default_action_type == "redirect" ? var.default_action_redirect != null : true
      error_message = "Must specify `default_action_redirect` if `default_action_type` is \"redirect\""
    }

    precondition {
      condition     = var.default_action_type == "fixed-response" ? var.default_action_fixed_response != null : true
      error_message = "Must specify `default_action_fixed_response` if `default_action_type` is \"fixed-response\""
    }

    precondition {
      condition     = var.listener_protocol == "HTTPS" ? var.listener_certificate_arn != null : true
      error_message = "Variable `listener_certificate_arn` must be set if `listener_protocol` is \"HTTPS\""
    }

    precondition {
      condition     = var.listener_protocol == "HTTPS" ? var.listener_ssl_policy != null : true
      error_message = "Variable `listener_ssl_policy` must be set if `listener_protocol` is \"HTTPS\""
    }
  }
}
