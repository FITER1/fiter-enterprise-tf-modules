## Requirements
Get the correct ami to be used from AWS. The region where the VPN will be created matters.
## Providers
| Name | Version |
|--|--|
| [aws](https://registry.terraform.io/providers/hashicorp/aws/latest) | >= 4.47 |

## Modules

## Resources
| Name | Type |
|--|--|
| [random_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) |resource |
| [aws_key_pair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs
| Name | Description  | Type | Default | Required |
|--|--|--|--|--|
| create_vpn_server |Whether to create the OpenVPN server resources  | bool  | `true` | no |
| vpn_server_username | Admin Username to access server | string  | `"openvpn"` | no |
| vpn_server_port | Port to access server | number | `943` | no |
| vpn_server_instance_type | EC2 Instance type to deploy server | string | `"t2.micro"` | yes |
| vpn_server_ami | AMI to deploy server | string | `n\a` | yes |
| vpn_authorized_access_cidr |CIDR block to allow access to VPN | list(string) | `["0.0.0.0/0"]` | no |
| common_tags | (Required) Resource Tag | map(any) | `n\a` | yes |
|vpn_vpc_id | VPC in which the vpn will be created | string | `n\a` | yes |
| subnet_id | The ID of the subnet where the OpenVPN server will be launched | string | `n\a` | yes |
| ssh_key_path | local path in which the ssh key for the vpn server will be created | string | `n\a` | yes |
| key_name | Name of the SSH key to use for the OpenVPN server | string | `"openvpn_accessserver_key"` | no |
| private_dns_server | value of the private dns server, should be based on vpc cidr | string | `"172.16.0.2"` | no |


## Outputs
| Name | Description |
|--|--|
| openvpn_setup_instructions | Connection details when the VPN server has been created |
| openvpn_admin_password | The admin password for the OpenVPN server |
| openvpn_admin_port | The admin port for the OpenVPN server |
| access_vpn_url | The public URL address of the VPN server admin interface |
| client_vpn_url | The public URL address of the client VPN server interface |

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Usage
To use this module in your Terraform environment, include it in your Terraform configuration with the necessary parameters. Below is an example of how to use this module:

```hcl
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
```

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eip.openvpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_instance.openvpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_key_pair.generated_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_security_group.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [local_file.private_key_pem](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [tls_private_key.ssh_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | (Required) Resource Tag | `map(any)` | n/a | yes |
| <a name="input_create_vpn_server"></a> [create\_vpn\_server](#input\_create\_vpn\_server) | Whether to create the OpenVPN server resources | `bool` | `true` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Name of the SSH key to use for the OpenVPN server | `string` | `"openvpn_accessserver_key"` | no |
| <a name="input_private_dns_server"></a> [private\_dns\_server](#input\_private\_dns\_server) | value of the private dns server, should be based on vpc cidr | `string` | `"172.16.0.2"` | no |
| <a name="input_ssh_key_path"></a> [ssh\_key\_path](#input\_ssh\_key\_path) | Path to the SSH key to use for the OpenVPN server | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The ID of the subnet where the OpenVPN server will be launched | `string` | n/a | yes |
| <a name="input_vpn_authorized_access_cidr"></a> [vpn\_authorized\_access\_cidr](#input\_vpn\_authorized\_access\_cidr) | CIDR block to allow access to VPN | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_vpn_server_ami"></a> [vpn\_server\_ami](#input\_vpn\_server\_ami) | AMI to deploy server | `string` | n/a | yes |
| <a name="input_vpn_server_instance_type"></a> [vpn\_server\_instance\_type](#input\_vpn\_server\_instance\_type) | Instance type to deploy server | `string` | `"t2.micro"` | no |
| <a name="input_vpn_server_port"></a> [vpn\_server\_port](#input\_vpn\_server\_port) | Port to access server | `number` | `943` | no |
| <a name="input_vpn_server_username"></a> [vpn\_server\_username](#input\_vpn\_server\_username) | Admin Username to access server | `string` | `"openvpn"` | no |
| <a name="input_vpn_vpc_id"></a> [vpn\_vpc\_id](#input\_vpn\_vpc\_id) | VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_vpn_url"></a> [access\_vpn\_url](#output\_access\_vpn\_url) | The public URL address of the VPN server admin interface |
| <a name="output_client_vpn_url"></a> [client\_vpn\_url](#output\_client\_vpn\_url) | The public URL address of the client VPN server interface |
| <a name="output_openvpn_admin_password"></a> [openvpn\_admin\_password](#output\_openvpn\_admin\_password) | The admin password for the OpenVPN server |
| <a name="output_openvpn_admin_port"></a> [openvpn\_admin\_port](#output\_openvpn\_admin\_port) | The admin port for the OpenVPN server |
| <a name="output_openvpn_setup_instructions"></a> [openvpn\_setup\_instructions](#output\_openvpn\_setup\_instructions) | n/a |
<!-- END_TF_DOCS -->