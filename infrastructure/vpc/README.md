<!-- DO NOT UPDATE: Document auto-generated! -->
# AWS VPC Terraform Module

This module creates an AWS [VPC](https://aws.amazon.com/vpc/) along with associated networking components.

Resources required to support the VPC, such as subnets, NAT gateways, and route tables, are created as part of the module.
Subnets are automatically allocated across Availability Zones (AZs) and tagged for specific roles like public, private, or intra subnets.
NAT Gateway configurations are included to allow secure internet access for private subnets.

Additionally, VPC endpoints for services like Secrets Manager are deployed, with security groups managed as part of the module.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Usage
To use this module in your Terraform environment, include it in your Terraform configuration with the necessary parameters. Below is an example of how to use this module:

```hcl
module "vpc" {
  source                            = "../"
  environment                       = "development"      # Hardcoded environment
  customer                          = "example-customer" # Hardcoded customer name
  vpc_cidr                          = "10.0.0.0/16"      # Hardcoded VPC CIDR block
  enable_secretmanager_vpc_endpoint = false              # Hardcoded value to disable RDS public access
  common_tags = {
    Name        = "example-vpc"
    Environment = "production"
    Owner       = "exampleteam"
  } # Hardcoded common tags
}
```

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_endpoints"></a> [endpoints](#module\_endpoints) | terraform-aws-modules/vpc/aws//modules/vpc-endpoints | ~> 5.17.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 5.17.0 |

## Resources

| Name | Type |
|------|------|
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | (Required) Resource Tag | `map(any)` | n/a | yes |
| <a name="input_customer"></a> [customer](#input\_customer) | (Required) Name of Customer. ex: Fiter | `string` | n/a | yes |
| <a name="input_enable_karpenter_autoscaler"></a> [enable\_karpenter\_autoscaler](#input\_enable\_karpenter\_autoscaler) | Enabled Karpenter Autoscaler | `bool` | `true` | no |
| <a name="input_enable_nat_gateway"></a> [enable\_nat\_gateway](#input\_enable\_nat\_gateway) | (Optional) Should be true if you want to provision NAT Gateways for each of your private networks | `bool` | `true` | no |
| <a name="input_enable_network_endpoints"></a> [enable\_network\_endpoints](#input\_enable\_network\_endpoints) | Enable VPC Endpoints for the cluster | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | (Required) Environment e.g Dev, Stg, Prod | `string` | n/a | yes |
| <a name="input_single_nat_gateway"></a> [single\_nat\_gateway](#input\_single\_nat\_gateway) | (Optional) Should be true if you want to provision a single shared NAT Gateway across all of your private networks | `bool` | `true` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | (Required) VPC Cidr | `string` | n/a | yes |
| <a name="input_vpc_gateway_endpoints"></a> [vpc\_gateway\_endpoints](#input\_vpc\_gateway\_endpoints) | List of Services to create VPC Gateway Endpoints. Used for Private Clusters | `list(string)` | `[]` | no |
| <a name="input_vpc_interface_endpoints"></a> [vpc\_interface\_endpoints](#input\_vpc\_interface\_endpoints) | List of Services to create VPC interface Endpoints. Used for Private Clusters | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azs"></a> [azs](#output\_azs) | A list of availability zones specified as argument to this module |
| <a name="output_intra_subnets"></a> [intra\_subnets](#output\_intra\_subnets) | Subnet ID for intra subnets |
| <a name="output_nat_public_ips"></a> [nat\_public\_ips](#output\_nat\_public\_ips) | Public IPs of the NAT Gateways |
| <a name="output_private_route_table_ids"></a> [private\_route\_table\_ids](#output\_private\_route\_table\_ids) | Route Table ID's for the Private subnet |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | List of IDs of private subnets |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | List of IDs of public subnets |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | The CIDR block of the VPC |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
<!-- End of Document -->