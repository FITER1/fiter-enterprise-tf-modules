# EC2 instance with auto-discovered Amazon Linux 2023 AMI, key pair stored in SSM,
# and Session Manager access enabled by default.

# --- Dependencies ---

module "vpc" {
  source      = "./../../vpc"
  environment = "dev"
  customer    = "example-customer"
  vpc_cidr    = "10.0.0.0/16"
  common_tags = { Name = "example-customer-dev", Environment = "dev" }
}

# --- EC2 Instance ---

module "ec2" {
  source = "../"

  # Required variables
  instance_name = "example-customer-dev-bastion" # change to your instance name
  environment   = "dev"                          # change to your environment
  vpc_id        = module.vpc.vpc_id
  subnets       = module.vpc.private_subnets

  tags = {
    Name        = "example-customer-dev-bastion"
    Environment = "dev"
    ManagedBy   = "terraform"
  }

  # Key pair — set create_key_pair = true to generate a new key and store it in SSM
  # Parameter Store at /<environment>/ec2/key_pair/<key_name>.
  # Set to false if the key already exists in AWS and provide key_name directly.
  key_name        = "example-customer-dev-bastion" # change to your key pair name
  create_key_pair = true

  # Instance type (default: t3.micro)
  instance_type = "t3.micro" # right-size for your workload

  # AMI — leave empty to auto-discover the latest Amazon Linux 2023 x86_64
  # ami_image_id = "ami-xxxxxxxxxxxxxxxxx" # uncomment to pin to a specific AMI

  # Security group ingress rules — SSH access from within the VPC
  sg_ingress_rules = {
    ssh = {
      port     = 22
      protocol = "tcp"
      cidr     = "10.0.0.0/16" # restrict to your VPC CIDR or trusted CIDR range
    }
  }
}
