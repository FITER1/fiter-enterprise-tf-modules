module "vpc" {
  source                            = "../"
  environment                       = "development"      # Hardcoded environment
  customer                          = "example-customer" # Hardcoded customer name
  vpc_cidr                          = "10.0.0.0/16"      # Hardcoded VPC CIDR block
  enable_secretmanager_vpc_endpoint = false              # Hardcoded value to disable RDS public access
  common_tags = {
    Name        = "example-vpc"
    Environment = "production"
    Owner       = "exampleteam"
  } # Hardcoded common tags
}
