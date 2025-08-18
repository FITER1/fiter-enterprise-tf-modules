locals {
  map_subnets         = var.subnets
  subnet_id           = random_shuffle.subnet.result[0]
  security_group_ids  = var.create_security_group ? [aws_security_group.this[0].id] : var.security_group_ids
  key_name            = var.key_name
  tags = {
    Name = var.instance_name
  }

  common_tags = merge(var.tags, local.tags, { Managed-By = "Terraform" })
  timestamp   = formatdate("YYYYMMDDhhmmss", timestamp())
}
