module "vpc" {
  source      = "../../vpc"
  environment = "dev"
  customer    = "fiter"
  vpc_cidr    = "10.0.0.0/16"
  common_tags = { "name" = "example" }
}

module "redis_cache_pe" {
  source = "../"

  enabled                          = true
  vpc_cidr_block                   = module.vpc.vpc_cidr_block
  cache_identifier                 = "fiter-eu-west-2-pe-dev"
  availability_zones               = ["eu-west-2a", "eu-west-2b"]
  vpc_id                           = module.vpc.vpc_id
  create_security_group            = true
  subnets                          = concat(module.vpc.private_subnets, module.vpc.public_subnets)
  cluster_size                     = 2
  instance_type                    = "cache.t4g.micro"
  snapshot_retention_limit         = 30
  apply_immediately                = false
  multi_az_enabled                 = false
  automatic_failover_enabled       = true
  engine_version                   = "7.1"
  family                           = "redis7"
  at_rest_encryption_enabled       = false
  transit_encryption_enabled       = false
  cloudwatch_metric_alarms_enabled = false
  security_group_description       = "Grant Access to fiter Cache"
}
