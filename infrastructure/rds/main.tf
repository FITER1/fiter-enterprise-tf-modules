locals {
  db_port             = "3306"
  publicly_accessible = var.disable_rds_public_access ? false : true
  tags = {
    Name    = var.db_identifier
    OwnedBy = "Terraform"
  }
}

resource "aws_security_group" "service" {
  name        = "${var.db_identifier}-rds-sg"
  description = "Allow inbound traffic to RDS"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow RDS connection from inside VPC"
    from_port   = local.db_port
    to_port     = local.db_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    description = "Allow RDS connection from inside VPC"
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.vpc_cidr_block]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = local.tags
}

# db_instance_master_user_secret_arn

module "db" {
  source                      = "terraform-aws-modules/rds/aws"
  version                     = "6.1.1"
  identifier                  = var.db_identifier
  engine                      = var.engine
  engine_version              = var.engine_version
  instance_class              = var.instance_class
  allocated_storage           = var.db_storage_size
  max_allocated_storage       = var.max_allocated_storage
  allow_major_version_upgrade = false

  db_name                         = var.initial_db_name
  username                        = var.username
  port                            = local.db_port
  enabled_cloudwatch_logs_exports = var.cloudwatch_logs_names
  vpc_security_group_ids          = [aws_security_group.service.id]

  backup_retention_period = var.backup_retention_period
  maintenance_window      = var.maintenance_window
  backup_window           = var.backup_window
  parameters              = var.parameters
  apply_immediately       = true


  manage_master_user_password = var.manage_master_user_password
  monitoring_interval         = var.monitoring_interval
  monitoring_role_name        = "${var.db_identifier}RDSMonitoringRole"
  create_monitoring_role      = var.create_monitoring_role

  tags = local.tags

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = var.rds_subnets #module.vpc.public_subnets

  # DB parameter group
  family = var.rds_family

  # DB option group
  major_engine_version = var.major_engine_version

  skip_final_snapshot = true
  # Database Deletion Protection change on production
  deletion_protection = var.deletion_protection
  # deletion_protection = var.rds_db_delete_protection
  publicly_accessible = local.publicly_accessible # set to false to enforce it is not publicly accessible

}


module "credential_generator" {
  source                 = "terraform-aws-modules/lambda/aws"
  version                = "2.7.0"
  function_name          = "${var.db_identifier}-rds-lambda"
  description            = "Creates Database Users"
  handler                = "index.lambda_handler"
  runtime                = "python3.11"
  source_path            = "${path.module}/lambda"
  vpc_subnet_ids         = var.intra_subnets
  vpc_security_group_ids = [aws_security_group.service.id]
  attach_network_policy  = true

  layers = [module.pymysql_layer.lambda_layer_arn]

  environment_variables = {
    ADMIN_SECRET_NAME = module.db.db_instance_master_user_secret_arn
    DB_HOST           = module.db.db_instance_address
    ADMIN_DB_NAME     = var.initial_db_name
    DB_IDENTIFIER     = var.db_identifier
  }

  attach_policy_json = true
  # least privilege condition tag should be dynamic
  policy_json = <<-EOT
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "secretsmanager:GetSecretValue",
                    "secretsmanager:DeleteSecret"
                ],
                "Resource": ["*"]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "secretsmanager:CreateSecret",
                    "secretsmanager:ListSecrets",
                    "secretsmanager:DescribeSecret",
                    "secretsmanager:TagResource",
                    "secretsmanager:GetRandomPassword"
                ],
                "Resource": ["*"]
            }
        ]
    }
  EOT

  depends_on = [
    module.db,
    module.pymysql_layer
  ]
  tags = local.tags
}

module "pymysql_layer" {
  source                 = "terraform-aws-modules/lambda/aws"
  version                = "6.0.0"
  create_layer           = true
  layer_name             = "pymysql-layer"
  description            = "PythonMySQL Dependency needed for Lambda Function"
  compatible_runtimes    = ["python3.11"]
  create_package         = false
  local_existing_package = "${path.module}/layers/pymysql.zip"
}

# Invoke to create users
resource "aws_lambda_invocation" "db_service" {
  for_each      = toset(var.db_service_users)
  function_name = module.credential_generator.lambda_function_arn

  input = jsonencode({
    "USERNAME" = each.value
  })
  lifecycle_scope = "CRUD"
  depends_on = [
    module.db,
    module.pymysql_layer,
    module.credential_generator
  ]
}

# improvements to be done
# ability to create new db
# add output of ARN to function to avoid user having to check for arn
# further scope down permission, dev vs service permissions
