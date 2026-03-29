# OIDC-based IAM roles for EKS workloads (ALB, ArgoCD, External Secrets, etc.)
# Requires a running EKS cluster — VPC and EKS are included as dependencies.

# --- Dependencies ---

module "vpc" {
  source      = "./../../vpc"
  environment = "dev"
  customer    = "example-customer"
  vpc_cidr    = "10.0.0.0/16"
  common_tags = { Name = "example-customer-dev", Environment = "dev" }
}

module "eks" {
  source          = "./../../eks_cluster"
  environment     = "dev"
  customer        = "example-customer"
  cluster_version = "1.31"
  common_tags     = { Name = "example-customer-dev", Environment = "dev" }

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.private_subnets
  route_table_ids = module.vpc.private_route_table_ids

  aws_auth_users = []
  aws_auth_roles = []

  node_groups_attributes = {
    general = {
      name                    = "example-customer-dev-general"
      instance_types          = ["t3a.medium"]
      capacity_type           = "ON_DEMAND"
      ami_type                = "AL2_x86_64"
      taints                  = []
      max_size                = 3
      min_size                = 1
      desired_size            = 1
      disk_size               = 50
      subnet_ids              = module.vpc.private_subnets
      pre_bootstrap_user_data = ""
    }
  }

  node_security_group_additional_rules = {}
}

# --- EKS IAM Roles ---

module "eks_iam_roles" {
  source = "../"

  # Required variables
  eks_cluster_name    = module.eks.cluster_name
  cluster_provider_arn = module.eks.oidc_provider_arn # OIDC provider ARN (not the issuer URL)
  region              = "eu-west-1"                   # change to your AWS region

  # Enable the roles your cluster needs — all default to false except external_secrets and eks_log
  enable_alb_controller     = true  # IAM role for AWS Load Balancer Controller
  enable_argocd             = false # IAM role for ArgoCD (S3/Secrets Manager access)
  enable_cluster_autoscaler = false # IAM role for Cluster Autoscaler
  enable_external_dns       = false # IAM role for External DNS

  # External Secrets operator role (enabled by default)
  eks_external_secret_enabled = true

  # EKS log bucket role (enabled by default) — references the bucket created by the eks_cluster module
  enable_eks_log_bucket = true
  eks_log_bucket        = module.eks.eks_log_bucket_arn

  additional_policies = {} # add custom IAM policies for workload-specific service accounts
}
