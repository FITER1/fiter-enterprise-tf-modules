# Shared security group allowing HTTPS access from specific IP ranges.

# --- Dependencies ---

module "vpc" {
  source      = "./../../vpc"
  environment = "dev"
  customer    = "example-customer"
  vpc_cidr    = "10.0.0.0/16"
  common_tags = { Name = "example-customer-dev", Environment = "dev" }
}

# --- Security Group ---

module "infra_security_group" {
  source = "../"

  name   = "example-customer-dev-infra-sg"
  vpc_id = module.vpc.vpc_id

  security_group_rules = [
    {
      name        = "office-vpn"
      ip          = "203.0.113.0/24" # change to your office/VPN egress CIDR
      description = "Allow access from office VPN"
    },
    {
      name        = "monitoring"
      ip          = "10.0.2.0/24" # change to your monitoring subnet CIDR
      description = "Allow access from monitoring servers"
    },
  ]

  ports = [443, 8080] # ports to open for the rules above

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
