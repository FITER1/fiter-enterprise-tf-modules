module "vpc" {
  source      = "../"
  environment = "dev"
  customer    = "example-customer" # change to your customer/project name
  vpc_cidr    = "10.0.0.0/16"
  common_tags = {
    Name        = "example-customer-dev"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
