data "aws_availability_zones" "available" {}

locals {
  name = "${var.customer}-${var.environment}-vpc"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_tag = {
    "kubernetes.io/role/internal-elb" = 1
  }

  karpenter_tag = {
    "karpenter.sh/discovery" = "${var.customer}-${var.environment}"
    type                     = "private"
  }
  private_subnet_tags = var.enable_karpenter_autoscaler ? merge(local.private_tag, local.karpenter_tag) : local.private_tag
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name = local.name
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 52)]

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
    type                     = "public"
  }

  private_subnet_tags = local.private_subnet_tags
  tags                = var.common_tags
}


module "endpoints" {
  count  = var.enable_secretmanager_vpc_endpoint ? 1 : 0
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id                = module.vpc.vpc_id
  create_security_group = true

  security_group_name_prefix = "${local.name}-vpc-endpoints-"
  security_group_description = "VPC endpoint security group"
  security_group_rules = {
    ingress_https = {
      description = "HTTPS from VPC"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
  }
  subnet_ids = module.vpc.intra_subnets

  endpoints = {
    secretsmanager = {
      # interface endpoint
      service             = "secretsmanager"
      private_dns_enabled = true
      tags                = { Name = "secretsmanager-vpc-endpoint" }
    },
  }
}


resource "aws_route53_zone" "private_zone" {
  count = var.enable_private_zone ? 1 : 0
  name = var.private_zone_host_name
  vpc {
    vpc_id = module.vpc.vpc_id
  }
  depends_on = [ module.vpc ]
  tags = var.common_tags
}
