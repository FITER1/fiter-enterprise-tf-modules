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

  interface_endpoints = { for endpoint in var.vpc_interface_endpoints : endpoint => {
    service             = endpoint
    service_type        = "Interface"
    private_dns_enabled = true
    tags = {
      Name = "${endpoint}-vpc-endpoint"
    }
    }
  }

  gateway_endpoint = { for endpoint in var.vpc_gateway_endpoints : endpoint => {
    service      = endpoint
    service_type = "Gateway"
    tags = {
      Name = "${endpoint}-vpc-endpoint"
    }
    route_table_ids = module.vpc.private_route_table_ids
    }
  }

  endpoints = merge(local.interface_endpoints, local.gateway_endpoint)
}