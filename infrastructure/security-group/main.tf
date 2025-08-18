/* 
 * # Security Group Module
 *
 * This module provisions a security group with the specified rules.
 *
*/

locals {
  security_group_list = flatten([for addr in var.security_group_rules :
    [for port in var.ports : merge(addr, { port = port })]
  ])
}

resource "aws_security_group" "service" {
  name        = "${var.name}-sg"
  description = "Allow inbound traffic to RDS"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.name}-sg" })
}


resource "aws_vpc_security_group_ingress_rule" "access_ingress" {
  for_each          = { for group in local.security_group_list : "${group.name}-${group.port}" => group }
  security_group_id = aws_security_group.service.id
  description       = each.value.description
  cidr_ipv4         = each.value.ip
  from_port         = each.value.port
  ip_protocol       = "tcp"
  to_port           = each.value.port
}

resource "aws_vpc_security_group_egress_rule" "egress" {
  security_group_id = aws_security_group.service.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
