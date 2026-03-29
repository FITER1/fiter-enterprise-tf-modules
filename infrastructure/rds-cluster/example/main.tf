# Aurora PostgreSQL-compatible RDS cluster with a single writer instance.

# --- Dependencies ---

module "vpc" {
  source      = "./../../vpc"
  environment = "dev"
  customer    = "example-customer"
  vpc_cidr    = "10.0.0.0/16"
  common_tags = { Name = "example-customer-dev", Environment = "dev" }
}

# --- RDS Cluster ---

module "rds_cluster" {
  source = "../"

  db_identifier = "example-customer-dev-db" # alphanumeric and hyphens only
  username      = "postgres"                # change to your preferred admin username
  initial_db_name = "appdb"

  # Engine
  engine         = "postgres"
  engine_version = "16"
  rds_family     = "postgres16"

  # Sizing
  instance_class = "db.t3.medium" # right-size for your workload
  db_storage_size = 50

  # Networking
  vpc_id                = module.vpc.vpc_id
  subnets               = module.vpc.private_subnets
  vpc_availability_zones = ["eu-west-1a", "eu-west-1b"] # change to AZs in your region

  disable_rds_public_access = true
  skip_final_snapshot       = true  # set to false in production to retain a final snapshot on destroy

  tags = {
    Name        = "example-customer-dev-db"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
