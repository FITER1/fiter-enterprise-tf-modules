# Generic RDS
module "rds" {
  source                                 = "../"
  db_identifier                          = "mydb1"                                # Unique identifier for the RDS instance
  username                               = "admin"                                # Hardcoded username
  vpc_id                                 = "vpc-12345678"                         # Hardcoded VPC ID
  vpc_cidr_block                         = "10.0.0.0/16"                          # Hardcoded VPC CIDR block
  rds_subnets                            = ["subnet-11111111", "subnet-22222222"] # Hardcoded RDS subnets
  initial_db_name                        = "exampledb"                            # Hardcoded initial database name
  instance_class                         = "db.t3.medium"                         # Instance type
  intra_subnets                          = ["subnet-33333333", "subnet-44444444"] # Hardcoded intra subnets
  db_service_users                       = ["service-user-1", "service-user-2"]   # Hardcoded RDS service users
  disable_rds_public_access              = true                                   # Disable public access to RDS
  allowed_cidrs                          = ["192.168.1.0/24", "10.0.0.0/16"]      # Allowed CIDR ranges
  rds_db_delete_protection               = true                                   # Enable deletion protection
  engine_version                         = "8.0"                                  # Engine version for MySQL
  major_engine_version                   = "8"                                    # Major engine version for MySQL
  engine                                 = "mysql"                                # Database engine
  rds_family                             = "mysql8.0"                             # RDS family for MySQL
  cloudwatch_logs_names                  = ["error", "general", "slowquery"]      # CloudWatch log group names
  db_port                                = 3306                                   # Database port for MySQL
  db_storage_size                        = 100                                    # Storage size in GB
  cloudwatch_log_group_retention_in_days = 14                                     # Retention period for CloudWatch logs
  create_cloudwatch_log_group            = true                                   # Whether to create CloudWatch log group
  encrypyt_db_storage                    = true                                   # Encrypt DB storage
  region                                 = "eu-west-1"                            # AWS region]
  environment                            = "dev"                                  # Environment
}

# RDS From Snapshot
module "rds-snapshot" {
  source                    = "../"
  db_identifier             = "mydb1"
  username                  = "admin"
  snapshot_name             = "mydb-snapshot" # <======= snapshot identifier
  vpc_id                    = "vpc-12345678"
  vpc_cidr_block            = "10.0.0.0/16"
  rds_subnets               = ["subnet-11111111", "subnet-22222222"]
  initial_db_name           = "exampledb"
  instance_class            = "db.t3.medium"
  intra_subnets             = ["subnet-33333333", "subnet-44444444"]
  db_service_users          = ["service-user-1", "service-user-2"]
  disable_rds_public_access = true
  # ...
}

# RDS With Read Replica
module "rds-replicas" {
  source                    = "../"
  db_identifier             = "mydb1"
  username                  = "admin"
  replicate_source_db       = module.rds.db_identifier # <======= source db identifier
  vpc_id                    = "vpc-12345678"
  vpc_cidr_block            = "10.0.0.0/16"
  rds_subnets               = ["subnet-11111111", "subnet-22222222"]
  initial_db_name           = "exampledb"
  instance_class            = "db.t3.medium"
  intra_subnets             = ["subnet-33333333", "subnet-44444444"]
  db_service_users          = ["service-user-1", "service-user-2"]
  disable_rds_public_access = true
  allowed_cidrs             = ["192.168.1.0/24", "10.0.0.0/16"]
  # ...
}