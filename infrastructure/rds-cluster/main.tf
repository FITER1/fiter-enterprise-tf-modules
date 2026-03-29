################################################################################
# RDS Aurora Module
################################################################################

module "aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 10.0"

  name                   = var.db_identifier
  port                   = var.port
  engine                 = var.engine
  engine_version         = var.engine_version
  master_username        = var.username
  database_name          = var.initial_db_name
  vpc_id                 = var.vpc_id
  create_db_subnet_group = true
  subnets                = var.subnets
  create_monitoring_role = var.create_monitoring_role
  instances              = var.cluster_instance_override

  manage_master_user_password_rotation                   = false
  master_user_password_rotation_automatically_after_days = 30

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  cluster_performance_insights_enabled = false

  autoscaling_enabled          = false
  create_security_group        = true
  security_group_ingress_rules = var.security_group_ingress_rules
  security_group_egress_rules  = var.security_group_egress_rules
  cluster_parameter_group      = var.cluster_parameter_group


  # Multi-AZ
  availability_zones = var.vpc_availability_zones
  allocated_storage  = var.db_storage_size
  iops               = var.iops
  storage_type       = var.storage_type

  cluster_ca_cert_identifier = var.ca_cert_identifier

  skip_final_snapshot = var.skip_final_snapshot
  deletion_protection = var.rds_db_delete_protection
  apply_immediately   = var.apply_immediately
  tags                = var.tags
}
