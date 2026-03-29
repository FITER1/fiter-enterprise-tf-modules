# Redis ElastiCache replication group with 2 nodes across availability zones.

# --- Dependencies ---

module "vpc" {
  source      = "./../../vpc"
  environment = "dev"
  customer    = "example-customer"
  vpc_cidr    = "10.0.0.0/16"
  common_tags = { Name = "example-customer-dev", Environment = "dev" }
}

# --- ElastiCache ---

module "redis" {
  source = "../"

  enabled          = true                         # set to false to destroy all resources without removing config
  cache_identifier = "example-customer-dev-redis" # change to your identifier (alphanumeric and hyphens only)
  vpc_id           = module.vpc.vpc_id
  vpc_cidr_block   = module.vpc.vpc_cidr_block
  subnets          = module.vpc.private_subnets

  # Engine
  engine_version = "7.1"
  family         = "redis7" # must match engine_version major

  # Cluster sizing
  instance_type              = "cache.t4g.micro" # right-size for your workload
  cluster_size               = 2
  availability_zones         = ["eu-west-1a", "eu-west-1b"] # change to your target AZs
  automatic_failover_enabled = true                         # required when cluster_size > 1
  multi_az_enabled           = false

  # Snapshots
  snapshot_retention_limit = 7 # days; set to 0 to disable automated snapshots

  # Encryption
  at_rest_encryption_enabled = true
  transit_encryption_enabled = false

  # Security group
  create_security_group      = true
  security_group_description = "ElastiCache Redis access for example-customer-dev"

  apply_immediately = false # set to true to apply changes immediately (causes brief downtime)
}
