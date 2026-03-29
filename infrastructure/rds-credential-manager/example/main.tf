# RDS Credential Manager — provisions a Lambda function that creates and rotates
# database service users, storing credentials in AWS Secrets Manager.

# --- Dependencies ---

module "vpc" {
  source      = "./../../vpc"
  environment = "dev"
  customer    = "example-customer"
  vpc_cidr    = "10.0.0.0/16"
  common_tags = { Name = "example-customer-dev", Environment = "dev" }
}

module "rds" {
  source = "./../../rds"

  db_identifier  = "example-customer-dev-db"
  environment    = "dev"
  instance_class = "db.t3.medium"

  engine               = "postgres"
  engine_version       = "16.4"
  major_engine_version = "16"
  rds_family           = "postgres16"
  db_port              = 5432
  initial_db_name      = "postgres"

  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
  rds_subnets    = module.vpc.private_subnets

  disable_rds_public_access   = true
  manage_master_user_password = true
  storage_type                = "gp3"
}

# --- RDS Credential Manager ---

module "credential_manager" {
  source = "../"

  name        = "example-customer-dev-db-creator" # change to your identifier
  environment = "dev"
  region      = "eu-west-1" # change to your AWS region

  engine = "postgres"

  # Networking — Lambda runs inside the VPC to reach the RDS instance
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = module.vpc.vpc_cidr_block
  subnets            = module.vpc.private_subnets
  security_group_ids = [module.rds.rds_security_group]

  # RDS connection details — wired from RDS module outputs
  admin_secret_arn    = module.rds.db_instance_master_user_secret_arn
  database_host       = module.rds.db_instance_address
  database_admin_db   = "postgres"
  database_identifier = module.rds.db_identifier

  # Lambda source — use "image" for a container image or "zip" for a packaged zip
  function_source = "image"
  docker_image    = "123456789012.dkr.ecr.eu-west-1.amazonaws.com/postgres-db-manager:latest" # change to your ECR image URI

  # Service users to create in the database
  db_service_users = [
    {
      user        = "app_user"  # alphanumeric and underscores only
      access_type = "readwrite" # "readwrite" or "readonly"
      db_owner    = "postgres"  # database role that owns the schemas
      databases   = ["appdb"]   # databases this user should access
    },
    {
      user        = "reporting_user"
      access_type = "readonly"
      db_owner    = "postgres"
      databases   = ["appdb"]
    },
  ]

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
