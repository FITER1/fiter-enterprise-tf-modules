/**
 * # AWS RDS Terraform Module
 *
 * This module provisions an AWS [RDS Database Instance](https://aws.amazon.com/rds/) along with supporting resources such as Security Groups, Read Replicas, and IAM Lambda integration.
 *
 * Resources created include:
 * - RDS instances with customizable configurations.
 * - Security Groups with ingress and egress rules.
 * - Read Replicas to enhance performance.
 * - Lambda functions for credential management and database initialization.
 * - IAM roles and policies for secure access.
 *
 * The module ensures seamless database access through integration with AWS Secrets Manager and Session Manager for secure credential storage and retrieval.
 *
*/


locals {
  secret_path               = "${var.environment}/${var.db_identifier}"
}

data "aws_caller_identity" "current" {}

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

  db_name                                = var.initial_db_name
  username                               = var.username
  port                                   = var.db_port
  enabled_cloudwatch_logs_exports        = var.cloudwatch_logs_names
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days
  create_cloudwatch_log_group            = var.create_cloudwatch_log_group
  vpc_security_group_ids                 = [aws_security_group.service.id]

  backup_retention_period = var.backup_retention_period
  maintenance_window      = var.maintenance_window
  backup_window           = var.backup_window

  snapshot_identifier         = var.snapshot_name
  manage_master_user_password = var.manage_master_user_password
  monitoring_interval         = var.monitoring_interval
  monitoring_role_name        = "${var.db_identifier}RDSMonitoringRole"
  create_monitoring_role      = var.create_monitoring_role
  storage_type                = var.storage_type
  iops                        = var.iops
  storage_encrypted           = var.encrypt_db_storage
  ca_cert_identifier          = var.ca_cert_identifier
  replicate_source_db         = var.replicate_source_db
  multi_az                    = var.enable_multi_az

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
