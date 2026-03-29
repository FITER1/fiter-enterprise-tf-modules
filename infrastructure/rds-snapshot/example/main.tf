# RDS instance provisioned from a snapshot, with Lambda-based credential rotation.
# Postgres example — change engine/family/port variables for MySQL.

# --- Dependencies ---

module "vpc" {
  source      = "./../../vpc"
  environment = "dev"
  customer    = "example-customer"
  vpc_cidr    = "10.0.0.0/16"
  common_tags = { Name = "example-customer-dev", Environment = "dev" }
}

# --- RDS from Snapshot ---

module "rds_snapshot" {
  source = "../"

  db_identifier    = "example-customer-dev-restored" # alphanumeric and hyphens only
  snapshot_db_name = "example-customer-dev-snapshot" # existing snapshot identifier in AWS
  username         = "postgres"                      # must match the snapshot's admin username
  initial_db_name  = "appdb"
  instance_class   = "db.t3.medium"

  # Engine — must match the engine used when the snapshot was taken
  engine               = "postgres"
  engine_version       = "16"
  major_engine_version = "16"
  rds_family           = "postgres16"
  db_port              = 5432

  # Networking
  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
  rds_subnets    = module.vpc.private_subnets
  intra_subnets  = module.vpc.intra_subnets # used for Lambda credential manager placement

  disable_rds_public_access = true
}
