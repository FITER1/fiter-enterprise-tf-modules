<!-- DO NOT UPDATE: Document auto-generated! -->
# AWS EC2 Terraform module

This module creates an AWS [EC2 Instances](https://aws.amazon.com/ec2/) on AWS.

Resources needed to support the ec2 instance such as Keypair, Security Group are created as part of the module.
The Generated Key is stored under System Manager Parameter store with the Instance name. Instance can also be accessed using Session Manager which is deployed as part of the module.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.7.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |

## Usage
To use this module in your Terraform environment, include it in your Terraform configuration with the necessary parameters. Below is an example of how to use this module:

```hcl
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
```

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2"></a> [ec2](#module\_ec2) | terraform-aws-modules/ec2-instance/aws | ~> 6.0 |
| <a name="module_key_pair"></a> [key\_pair](#module\_key\_pair) | terraform-aws-modules/key-pair/aws | 2.1.1 |

## Resources

| Name | Type |
|------|------|
| [aws_ebs_volume.data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ssm_parameter.aws_key_pair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_volume_attachment.data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_vpc_security_group_egress_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [random_shuffle.subnet](https://registry.terraform.io/providers/hashicorp/random/3.7.2/docs/resources/shuffle) | resource |
| [aws_ami.amazon_linux](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_ebs_volumes"></a> [additional\_ebs\_volumes](#input\_additional\_ebs\_volumes) | List of Map of Additional EBS Volumes | `list(any)` | `[]` | no |
| <a name="input_ami_image_id"></a> [ami\_image\_id](#input\_ami\_image\_id) | ID of AMI to use for the instance | `string` | `""` | no |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | Whether to associate a public IP address with an instance in a VPC | `bool` | `null` | no |
| <a name="input_create_eip"></a> [create\_eip](#input\_create\_eip) | Whether to create an Elastic IP for the instance | `bool` | `false` | no |
| <a name="input_create_key_pair"></a> [create\_key\_pair](#input\_create\_key\_pair) | Create AWS Key Pair, Set to False if Key already exists in AWS | `bool` | `false` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Create EC2 Security Group, Set to False to Use Existing Security Group | `bool` | `true` | no |
| <a name="input_create_timeout"></a> [create\_timeout](#input\_create\_timeout) | value of the timeout to create the resource | `string` | `"10m"` | no |
| <a name="input_default_ami_filter"></a> [default\_ami\_filter](#input\_default\_ami\_filter) | Default AMI filter to use if ami\_image\_id is not provided | `string` | `"al2023-ami-2023.*-kernel-6.1-*"` | no |
| <a name="input_delete_timeout"></a> [delete\_timeout](#input\_delete\_timeout) | value of the timeout to delete the resource | `string` | `"10m"` | no |
| <a name="input_disable_api_termination"></a> [disable\_api\_termination](#input\_disable\_api\_termination) | If true, enables EC2 Instance Termination Protection | `bool` | `false` | no |
| <a name="input_ebs_volume_size"></a> [ebs\_volume\_size](#input\_ebs\_volume\_size) | EBS Volume Size | `number` | `50` | no |
| <a name="input_ebs_volume_type"></a> [ebs\_volume\_type](#input\_ebs\_volume\_type) | EBS Volume Type | `string` | `"gp3"` | no |
| <a name="input_enable_encrypted_volume"></a> [enable\_encrypted\_volume](#input\_enable\_encrypted\_volume) | Enable EBS Volume Encryption | `bool` | `true` | no |
| <a name="input_enable_hibernation_support"></a> [enable\_hibernation\_support](#input\_enable\_hibernation\_support) | If true, the launched EC2 instance will support hibernation | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment for the resources, e.g., dev, staging, prod | `string` | n/a | yes |
| <a name="input_ignore_ami_changes"></a> [ignore\_ami\_changes](#input\_ignore\_ami\_changes) | Whether to ignore changes to the AMI ID | `bool` | `true` | no |
| <a name="input_instance_iam_policies"></a> [instance\_iam\_policies](#input\_instance\_iam\_policies) | Map of Policies to Add to Instance Profile | `map(any)` | `{}` | no |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | Name to be used on EC2 instance created | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Description: The type of instance to start | `string` | `"t3.micro"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Key name of the Key Pair to use for the instance | `string` | n/a | yes |
| <a name="input_metadata_options"></a> [metadata\_options](#input\_metadata\_options) | Metadata options for the EC2 instance | `map(string)` | <pre>{<br/>  "http_endpoint": "enabled",<br/>  "http_put_response_hop_limit": 2,<br/>  "http_tokens": "required"<br/>}</pre> | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of Existing Security Groups to Use, Ignored if Create Security Group is enabled | `list(string)` | `[]` | no |
| <a name="input_sg_ingress_cidr"></a> [sg\_ingress\_cidr](#input\_sg\_ingress\_cidr) | List of CIDRs to Allow in Security Group, Defaults to the VPC CIDR if ignored. (Deprecated in favor of sg\_ingress\_rules) | `list(string)` | `[]` | no |
| <a name="input_sg_ingress_ports"></a> [sg\_ingress\_ports](#input\_sg\_ingress\_ports) | List of Ingress Ports to Allow in Security Group (Deprecated in favor of sg\_ingress\_rules) | `list(number)` | <pre>[<br/>  80<br/>]</pre> | no |
| <a name="input_sg_ingress_protocol"></a> [sg\_ingress\_protocol](#input\_sg\_ingress\_protocol) | Ingress Protocol Name (Deprecated in favor of sg\_ingress\_rules) | `string` | `"tcp"` | no |
| <a name="input_sg_ingress_rules"></a> [sg\_ingress\_rules](#input\_sg\_ingress\_rules) | Map of Security Group Ingress Rules to Add, Ignored if Create Security | `map(any)` | `{}` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Name of VPC Subnets to Deploy EC2 | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Compulsory Tags For Terraform Resources, Must Contain Tribe, Squad and Domain | `map(any)` | n/a | yes |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | User data script to run on instance launch | `string` | `null` | no |
| <a name="input_user_data_base64"></a> [user\_data\_base64](#input\_user\_data\_base64) | Base64 encoded user data script to run on instance launch | `string` | `null` | no |
| <a name="input_user_data_replace_on_change"></a> [user\_data\_replace\_on\_change](#input\_user\_data\_replace\_on\_change) | Whether to replace the user data script on change | `bool` | `false` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where the EC2 instance will be launched | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | ID of the EC2 instance |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | Private IP address of the EC2 instance |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | public ip address |
| <a name="output_volume_ids"></a> [volume\_ids](#output\_volume\_ids) | List of EBS volume IDs attached to the instance |
<!-- End of Document -->