<!-- DO NOT UPDATE: Document auto-generated! -->
# Security Group Module

This module provisions a security group with the specified rules.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

## Usage
To use this module in your Terraform environment, include it in your Terraform configuration with the necessary parameters. Below is an example of how to use this module:

```hcl
module "infra_security_group" {
  source = "../"
  name   = "dev-infra-sg"
  vpc_id = "vpc-001"
  security_group_rules = [{
    name        = "user-1"
    ip          = "123.4.5.4/32"
    description = "Grant Access to DB from user 1"
  }]
  ports = [443]
  tags = {
    component   = "infra"
    environment = "dev"
  }

}
```

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_security_group.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.access_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the security group | `string` | n/a | yes |
| <a name="input_ports"></a> [ports](#input\_ports) | Port to allow traffic on | `list(number)` | n/a | yes |
| <a name="input_security_group_rules"></a> [security\_group\_rules](#input\_security\_group\_rules) | List of security group rules | <pre>list(object({<br/>    description = string<br/>    ip          = string<br/>    name        = string<br/>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the security group | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID From VPC Module | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group |
<!-- End of Document -->
<!-- BEGIN_TF_DOCS -->
# Security Group Module

This module provisions a security group with the specified rules.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

## Usage
To use this module in your Terraform environment, include it in your Terraform configuration with the necessary parameters. Below is an example of how to use this module:

```hcl
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
```

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_security_group.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.access_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the security group | `string` | n/a | yes |
| <a name="input_ports"></a> [ports](#input\_ports) | Port to allow traffic on | `list(number)` | n/a | yes |
| <a name="input_security_group_rules"></a> [security\_group\_rules](#input\_security\_group\_rules) | List of security group rules | <pre>list(object({<br/>    description = string<br/>    ip          = string<br/>    name        = string<br/>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the security group | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID From VPC Module | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group |
<!-- END_TF_DOCS -->