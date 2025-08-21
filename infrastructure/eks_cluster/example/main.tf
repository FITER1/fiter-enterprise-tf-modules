module "vpc" {
  source      = "../../vpc"
  environment = "dev"
  customer    = "fiter"
  vpc_cidr    = "10.0.0.0/16"
  common_tags = { "name" = "example" }
}

module "eks" {
  source          = "../"
  environment     = "dev"
  customer        = "fiter"
  cluster_version = "1.29"
  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.private_subnets
  route_table_ids = module.vpc.private_route_table_ids
  common_tags     = { "name" = "example" }
  node_security_group_additional_rules = [
    {
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      cidr_blocks = ["0.0.0.0/0"] # Allow HTTP traffic from anywhere
    },
    {
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_blocks = ["0.0.0.0/0"] # Allow HTTPS traffic from anywhere
    },
    {
      protocol        = "all"
      from_port       = 0
      to_port         = 0
      security_groups = ["sg-12345678"] # Allow all traffic within the specified security group
    }
  ]
  aws_auth_roles                 = ["arn:aws:iam::[account_id]:role/[role_name]"]
  aws_auth_users                 = ["iam_user_name"]
  cluster_endpoint_public_access = true
  node_groups_attributes = {
    general-1 = {
      name                    = "example"
      instance_types          = ["t3a.medium"]
      capacity_type           = "ON_DEMAND"
      ami_type                = "AL2_x86_64"
      taints                  = []
      max_size                = 5
      min_size                = 2
      desired_size            = 4
      disk_size               = 50
      subnet_ids              = module.vpc.private_subnets
      pre_bootstrap_user_data = ""
    }
  }
  assume_role_arn = "arn:aws:iam::[account_id]:role/[role_name]"
}
