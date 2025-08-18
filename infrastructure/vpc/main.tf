/**
 * # AWS VPC Terraform Module
 *
 * This module creates an AWS [VPC](https://aws.amazon.com/vpc/) along with associated networking components.
 *
 * Resources required to support the VPC, such as subnets, NAT gateways, and route tables, are created as part of the module. 
 * Subnets are automatically allocated across Availability Zones (AZs) and tagged for specific roles like public, private, or intra subnets. 
 * NAT Gateway configurations are included to allow secure internet access for private subnets.
 *
 * Additionally, VPC endpoints for services like Secrets Manager are deployed, with security groups managed as part of the module.
 *
 */

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.17.0"

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
  count                      = var.enable_network_endpoints ? 1 : 0
  source                     = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version                    = "~> 5.17.0"
  vpc_id                     = module.vpc.vpc_id
  create_security_group      = true
  subnet_ids                 = module.vpc.private_subnets
  endpoints                  = local.endpoints
  security_group_name_prefix = "${local.name}-endpoints-"
  security_group_description = "VPC endpoint security group"
  security_group_rules = {
    ingress_https = {
      description = "HTTPS from VPC"
      cidr_blocks = [var.vpc_cidr]
    }
  }
}
