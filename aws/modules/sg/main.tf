locals {
  # Tidy up ingress rules
  ingress_rules = [
    for rule in var.ingress_rules :
    {
      description                  = rule.description
      cidr_ipv4                    = rule.cidr_ipv4
      cidr_ipv6                    = rule.cidr_ipv6
      ip_protocol                  = upper(rule.ip_protocol)
      from_port                    = upper(rule.ip_protocol) == "ALL" ? null : rule.from_port
      to_port                      = upper(rule.ip_protocol) == "ALL" ? null : rule.from_port
      prefix_list_id               = rule.prefix_list_id
      referenced_security_group_id = rule.referenced_security_group_id
    }
  ]

  # Tidy up egress rules
  egress_rules = [
    for rule in var.egress_rules :
    {
      description                  = rule.description
      cidr_ipv4                    = rule.cidr_ipv4
      cidr_ipv6                    = rule.cidr_ipv6
      ip_protocol                  = upper(rule.ip_protocol)
      from_port                    = upper(rule.ip_protocol) == "ALL" ? null : rule.from_port
      to_port                      = upper(rule.ip_protocol) == "ALL" ? null : rule.from_port
      prefix_list_id               = rule.prefix_list_id
      referenced_security_group_id = rule.referenced_security_group_id
    }
  ]
}

resource "aws_security_group" "main" {
  name                   = var.use_name_prefix ? null : var.name
  name_prefix            = var.use_name_prefix ? var.name_prefix : null
  description            = var.description
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = var.revoke_rules_on_delete

  tags = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "main" {
  count = length(local.ingress_rules)

  security_group_id            = aws_security_group.main.id
  description                  = local.ingress_rules[count.index].description
  cidr_ipv4                    = local.ingress_rules[count.index].cidr_ipv4
  cidr_ipv6                    = local.ingress_rules[count.index].cidr_ipv6
  ip_protocol                  = local.ingress_rules[count.index].ip_protocol
  from_port                    = local.ingress_rules[count.index].from_port
  to_port                      = local.ingress_rules[count.index].to_port
  prefix_list_id               = local.ingress_rules[count.index].prefix_list_id
  referenced_security_group_id = local.ingress_rules[count.index].referenced_security_group_id
}

resource "aws_vpc_security_group_egress_rule" "main" {
  count = length(local.egress_rules)

  security_group_id            = aws_security_group.main.id
  description                  = local.egress_rules[count.index].description
  cidr_ipv4                    = local.egress_rules[count.index].cidr_ipv4
  cidr_ipv6                    = local.egress_rules[count.index].cidr_ipv6
  ip_protocol                  = local.egress_rules[count.index].ip_protocol
  from_port                    = local.egress_rules[count.index].from_port
  to_port                      = local.egress_rules[count.index].to_port
  prefix_list_id               = local.egress_rules[count.index].prefix_list_id
  referenced_security_group_id = local.egress_rules[count.index].referenced_security_group_id
}
