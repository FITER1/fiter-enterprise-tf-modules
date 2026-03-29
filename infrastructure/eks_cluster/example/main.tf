# EKS cluster with a managed node group.
# The VPC module is referenced as a local relative path dependency.

# --- Dependencies ---

module "vpc" {
  source      = "./../../vpc"
  environment = "dev"
  customer    = "example-customer"
  vpc_cidr    = "10.0.0.0/16"
  common_tags = { Name = "example-customer-dev", Environment = "dev" }
}

# --- EKS Cluster ---

module "eks" {
  source = "../"

  environment     = "dev"
  customer        = "example-customer"
  cluster_version = "1.31" # update to the latest supported EKS version as needed
  common_tags     = { Name = "example-customer-dev", Environment = "dev" }

  # Networking — wired from VPC dependency
  vpc_id                               = module.vpc.vpc_id
  subnets                              = module.vpc.private_subnets
  route_table_ids                      = module.vpc.private_route_table_ids
  node_security_group_additional_rules = {}

  # Cluster API endpoint access
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"] # restrict to your corporate egress IPs in production

  # Node groups
  node_groups_attributes = {
    general = {
      name                    = "example-customer-dev-general"
      instance_types          = ["t3a.medium"] # right-size for your workloads
      capacity_type           = "ON_DEMAND"
      ami_type                = "AL2_x86_64"
      taints                  = []
      max_size                = 5
      min_size                = 1
      desired_size            = 2
      disk_size               = 50
      subnet_ids              = module.vpc.private_subnets
      pre_bootstrap_user_data = ""
    }
  }
}
