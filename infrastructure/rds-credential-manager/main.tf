/**
 * # RDS Credential Manager
 * This Terraform configuration defines a module for managing AWS Lambda functions that handle RDS credential management. 
 * Function can be created as a zip file or as a Docker image. The Generated Credentials are stored in AWS Secrets manager
 * as `${var.environment}/${var.database_identifier}`
 *  
 */
data "aws_caller_identity" "current" {}

module "credential_manager" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.20.2"

  create         = true
  create_package = var.function_source == "zip"
  function_name  = "${var.name}-rds-lambda"
  description    = "Creates Database Users for ${var.name} RDS"

  architectures = ["x86_64"]
  handler       = lookup(local.lambda_type[var.function_source], "handler", local.defaults.handler)
  image_uri     = lookup(local.lambda_type[var.function_source], "image_uri", local.defaults.image_uri)
  runtime       = lookup(local.lambda_type[var.function_source], "runtime", local.defaults.runtime)
  source_path   = lookup(local.lambda_type[var.function_source], "source_path", local.defaults.source_path)
  layers        = lookup(local.lambda_type[var.function_source], "layers", local.defaults.layers)
  package_type  = lookup(local.lambda_type[var.function_source], "package_type", local.defaults.package_type)

  vpc_subnet_ids         = var.subnets
  vpc_security_group_ids = var.security_group_ids
  attach_network_policy  = true
  timeout                = var.timeout

  environment_variables = {
    ADMIN_SECRET_NAME = var.admin_secret_arn
    DB_HOST           = var.database_host
    ADMIN_DB_NAME     = var.database_admin_db
    DB_IDENTIFIER     = var.database_identifier
    SECRET_PATH       = local.secret_path
  }

  attach_policy_json = true
  policy_json        = data.aws_iam_policy_document.credential_manager_lambda.json

  tags = var.tags
}

data "aws_iam_policy_document" "credential_manager_lambda" {
  statement {
    sid    = "AllowSecretsManager"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [var.admin_secret_arn]
  }

  statement {
    sid    = "AllowSecretsManagerCreate"
    effect = "Allow"
    actions = [
      "secretsmanager:CreateSecret",
      "secretsmanager:ListSecrets",
      "secretsmanager:DescribeSecret",
      "secretsmanager:TagResource",
      "secretsmanager:GetRandomPassword"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "GetSecretUser"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DeleteSecret"
    ]
    resources = ["arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${local.secret_path}/*"]
  }
}

module "pymysql_layer" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "6.0.0"

  create                 = var.function_source == "zip"
  create_layer           = var.function_source == "zip"
  layer_name             = "${var.name}-pysql-layer"
  description            = "PythonMySQL Dependency needed for Lambda Function"
  compatible_runtimes    = ["python3.11"]
  create_package         = false
  local_existing_package = "${path.module}/layers/${local.lambda_layer[var.engine]}"
}

# Invoke for DB Initialization
resource "aws_lambda_invocation" "postgres_init" {
  count = var.engine == "postgres" && var.enable_credential_manager ? 1 : 0

  function_name   = module.credential_manager.lambda_function_arn
  lifecycle_scope = "CREATE_ONLY"
  input = jsonencode({
    "USERNAME"    = "ignore",
    "DATABASES"   = [],
    "DB_INIT"     = "True"
    "DB_OWNER"    = ""
    "ACCESS_TYPE" = "readonly"
  })
  depends_on = [module.endpoints]
}

# Invoke to create users
resource "aws_lambda_invocation" "db_service" {
  for_each = { for value in var.db_service_users : value.user => value }

  function_name   = module.credential_manager.lambda_function_arn
  lifecycle_scope = "CRUD"

  input = jsonencode({
    "USERNAME"    = each.value.user,
    "DATABASES"   = each.value.databases,
    "DB_OWNER"    = each.value.db_owner,
    "DB_INIT"     = "False"
    "ACCESS_TYPE" = each.value.access_type
  })

  depends_on = [
    module.endpoints,
    aws_lambda_invocation.postgres_init
  ]
}

module "endpoints" {
  count   = var.enable_secretmanager_vpc_endpoint ? 1 : 0
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.17.0"

  vpc_id                = var.vpc_id
  create_security_group = true

  security_group_name_prefix = "${var.name}-vpc-endpoints-"
  security_group_description = "VPC endpoint security group"
  security_group_rules = {
    ingress_https = {
      description = "HTTPS from VPC"
      cidr_blocks = [var.vpc_cidr]
    }
  }
  subnet_ids = var.subnets

  endpoints = {
    secretsmanager = {
      service             = "secretsmanager"
      private_dns_enabled = true
      tags                = { Name = "secretsmanager-vpc-endpoint" }
    },
  }
}
