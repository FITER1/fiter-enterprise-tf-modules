locals {
  map_subnets        = var.subnets
  subnet_id          = random_shuffle.subnet.result[0]
  security_group_ids = var.create_security_group ? [aws_security_group.this[0].id] : var.security_group_ids
  key_name           = var.key_name
  tags = {
    Name = var.instance_name
  }

  common_tags = merge(var.tags, local.tags, { Managed-By = "Terraform" })
  timestamp   = formatdate("YYYYMMDDhhmmss", timestamp())

  # Flatten sg_ingress_rules so each (rule_name, cidr) pair becomes a unique key.
  # aws_vpc_security_group_ingress_rule accepts only a single CIDR per rule (unlike
  # the removed aws_security_group_rule which accepted cidr_blocks as a list).
  sg_ingress_rules_flat = var.create_security_group ? {
    for item in flatten([
      for rule_name, rule in var.sg_ingress_rules : [
        for cidr in rule.cidr : {
          key      = "${rule_name}-${cidr}"
          port     = rule.port
          protocol = rule.protocol
          cidr     = cidr
        }
      ]
    ]) : item.key => item
  } : {}
}
