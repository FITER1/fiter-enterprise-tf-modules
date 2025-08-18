module "develop" {
  source                      = "../"
  vpc_id                      = "vpc-12345678"                         # Replace with your actual VPC ID
  vpc_cidr_block              = "10.0.0.0/16"                          # VPC CIDR block
  rds_subnets                 = ["subnet-12345678", "subnet-87654321"] # List of RDS subnets (private)
  instance_class              = "db.t3.small"
  intra_subnets               = ["subnet-23456789", "subnet-98765432"] # List of intra subnets
  disable_rds_public_access   = true
  engine_version              = "13"
  major_engine_version        = "13"
  engine                      = "postgres"
  rds_family                  = "postgres13"
  cloudwatch_logs_names       = ["postgresql", "upgrade"] # specific to postgres
  storage_type                = "io1"
  iops                        = 1000
  db_identifier               = "develop"
  db_storage_size             = "100"
  snapshot_db_name            = "example_snapshot"
  username                    = "example_username"
  initial_db_name             = null
  manage_master_user_password = false
  db_port                     = 5432
  encrypyt_db_storage         = true
  rds_db_delete_protection    = false
  apply_immediately           = false

  allowed_cidrs = [
    {
      "name" : "general-ingress"
      "ip" : "0.0.0.0/0",
      "description" : "Grant Access"
    }
  ]
  depends_on = [module.vpc]
}
