# MySQL RDS instance with master password managed by Secrets Manager.
# Variants for snapshot restore and read replica are shown as additional modules below.

# --- Dependencies ---

module "vpc" {
  source      = "./../../vpc"
  environment = "dev"
  customer    = "example-customer"
  vpc_cidr    = "10.0.0.0/16"
  common_tags = { Name = "example-customer-dev", Environment = "dev" }
}

# --- RDS Instance ---

module "rds" {
  source = "../"

  db_identifier  = "example-customer-dev-db" # alphanumeric and hyphens only
  instance_class = "db.t3.medium"
  environment    = "dev"

  # Engine
  engine               = "mysql"
  engine_version       = "8.0"
  major_engine_version = "8.0"
  rds_family           = "mysql8.0"
  db_port              = 3306
  initial_db_name      = "appdb"

  # Networking
  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
  rds_subnets    = module.vpc.private_subnets

  disable_rds_public_access   = true
  manage_master_user_password = true # stores master password in Secrets Manager

  # Storage
  db_storage_size    = 50
  encrypt_db_storage = true

  # Additional CIDR ingress (optional)
  allowed_cidrs = [
    {
      name        = "app-servers"
      ip          = "10.0.1.0/24" # change to your application subnet CIDR
      description = "Allow access from application servers"
    }
  ]
}

# --- RDS from Snapshot (uncomment to use) ---

# module "rds_from_snapshot" {
#   source = "../"
#
#   db_identifier   = "example-customer-dev-db-restored"
#   instance_class  = "db.t3.medium"
#   environment     = "dev"
#   snapshot_name   = "example-customer-dev-db-snapshot-id" # snapshot identifier in AWS
#
#   engine               = "mysql"
#   engine_version       = "8.0"
#   major_engine_version = "8.0"
#   rds_family           = "mysql8.0"
#   db_port              = 3306
#
#   vpc_id         = module.vpc.vpc_id
#   vpc_cidr_block = module.vpc.vpc_cidr_block
#   rds_subnets    = module.vpc.private_subnets
#
#   disable_rds_public_access = true
# }

# --- Read Replica (uncomment to use; primary must exist first) ---

# module "rds_replica" {
#   source = "../"
#
#   db_identifier       = "example-customer-dev-db-replica"
#   instance_class      = "db.t3.medium"
#   environment         = "dev"
#   read_replica        = true
#   replicate_source_db = module.rds.db_identifier
#
#   engine               = "mysql"
#   engine_version       = "8.0"
#   major_engine_version = "8.0"
#   rds_family           = "mysql8.0"
#   db_port              = 3306
#
#   vpc_id         = module.vpc.vpc_id
#   vpc_cidr_block = module.vpc.vpc_cidr_block
#   rds_subnets    = module.vpc.private_subnets
#
#   disable_rds_public_access = true
# }
