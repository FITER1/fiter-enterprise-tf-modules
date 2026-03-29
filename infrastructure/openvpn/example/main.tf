# OpenVPN Access Server on a public subnet with an Elastic IP.
# After apply, follow the openvpn_setup_instructions output to complete initial configuration.

# --- Dependencies ---

module "vpc" {
  source      = "./../../vpc"
  environment = "dev"
  customer    = "example-customer"
  vpc_cidr    = "10.0.0.0/16"
  common_tags = { Name = "example-customer-dev", Environment = "dev" }
}

# --- OpenVPN ---

module "openvpn" {
  source = "../"

  vpn_vpc_id = module.vpc.vpc_id
  subnet_id  = module.vpc.public_subnets[0] # must be a public subnet (requires route to IGW)

  vpn_server_ami = "ami-0123456789abcdef0"        # change to the OpenVPN AS AMI for your region
  ssh_key_path   = "/path/to/openvpn-key.pem"     # local path used to render setup instructions
  key_name       = "example-customer-dev-openvpn" # EC2 key pair name in AWS

  vpn_server_instance_type   = "t3.micro"    # t3.micro is sufficient for < 50 concurrent users
  vpn_authorized_access_cidr = ["0.0.0.0/0"] # restrict to your corporate egress IPs in production

  common_tags = {
    Name        = "example-customer-dev-openvpn"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
