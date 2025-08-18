/*
 * # AWS RDS Terraform Module
 *
 * This module provisions an RDS instance from a snapshot and manages related resources such as security groups, ingress, and egress rules.
 *
 * ## Features
 * - Creates an RDS instance using the AWS RDS module.
 * - Manages an RDS DB snapshot.
 * - Provisions and configures security groups, including ingress and egress rules.
 * - Configurable through input variables to adapt to different environments.
 *
 */
resource "aws_db_snapshot" "db" {
  db_instance_identifier = var.snapshot_db_name
  db_snapshot_identifier = "${var.snapshot_db_name}-snapshot-${formatdate("YYYY-MM-DD", timestamp())}"
  lifecycle {
    ignore_changes = [
      db_snapshot_identifier
    ]
  }
}

resource "aws_security_group" "service" {
  name        = "${var.db_identifier}-rds-sg"
  description = "Allow inbound traffic to RDS"
  vpc_id      = var.vpc_id
  tags        = local.tags
}

resource "aws_vpc_security_group_ingress_rule" "vpc_ingress" {
  security_group_id = aws_security_group.service.id
  cidr_ipv4         = var.vpc_cidr_block
  from_port         = var.db_port
  ip_protocol       = "tcp"
  to_port           = var.db_port
}

resource "aws_vpc_security_group_ingress_rule" "access_ingress" {
  for_each          = local.security_group_map
  security_group_id = aws_security_group.service.id
  description       = each.value.description
  cidr_ipv4         = each.value.ip
  from_port         = each.value.port == null ? var.db_port : each.value.port
  ip_protocol       = "tcp"
  to_port           = var.db_port
}

resource "aws_vpc_security_group_egress_rule" "egress" {
  security_group_id = aws_security_group.service.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

module "db" {
  source                      = "terraform-aws-modules/rds/aws"
  version                     = "~> 6.12.0"
  identifier                  = var.db_identifier
  engine                      = var.engine
  engine_version              = var.engine_version
  instance_class              = var.instance_class
  allocated_storage           = var.db_storage_size
  allow_major_version_upgrade = false

  db_name                         = var.initial_db_name
  username                        = var.username
  port                            = local.db_port
  enabled_cloudwatch_logs_exports = var.cloudwatch_logs_names
  vpc_security_group_ids          = [aws_security_group.service.id]

  backup_retention_period = var.backup_retention_period
  maintenance_window      = var.maintenance_window
  backup_window           = var.backup_window

  snapshot_identifier         = aws_db_snapshot.db.db_snapshot_identifier
  manage_master_user_password = var.manage_master_user_password # only add if you want to change password of snapshot
  monitoring_interval         = var.monitoring_interval
  monitoring_role_name        = "${var.db_identifier}RDSMonitoringRole"
  create_monitoring_role      = var.create_monitoring_role
  storage_encrypted           = var.encrypyt_db_storage
  storage_type                = var.storage_type
  iops                        = var.iops
  ca_cert_identifier          = var.ca_cert_identifier

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period
  apply_immediately                     = var.apply_immediately

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = var.rds_subnets

  # DB parameter group
  family = var.rds_family

  # DB option group
  major_engine_version = var.major_engine_version

  skip_final_snapshot = true
  # Database Deletion Protection change on production
  deletion_protection = var.rds_db_delete_protection

  publicly_accessible = local.publicly_accessible # set to false to enforce it is not publicly accessible

  tags = local.tags
}
