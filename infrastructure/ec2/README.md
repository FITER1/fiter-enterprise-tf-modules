<!-- DO NOT UPDATE: Document auto-generated! -->
# AWS EC2 Terraform module

This module creates an AWS [EC2 Instances](https://aws.amazon.com/ec2/) on AWS.

Resources needed to support the ec2 instance such as Keypair, Security Group are created as part of the module.
The Generated Key is stored under System Manager Parameter store with the Instance name. Instance can also be accessed using Session Manager which is deployed as part of the module.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.47 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.7.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.47 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.1 |

## Usage
To use this module in your Terraform environment, include it in your Terraform configuration with the necessary parameters. Below is an example of how to use this module:

```hcl
# no calling module for ec2
```

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2"></a> [ec2](#module\_ec2) | terraform-aws-modules/ec2-instance/aws | ~> 5.5.0 |
| <a name="module_key_pair"></a> [key\_pair](#module\_key\_pair) | terraform-aws-modules/key-pair/aws | 2.0.3 |

## Resources

| Name | Type |
|------|------|
| [aws_ebs_volume.data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ssm_parameter.aws_key_pair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_volume_attachment.data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [random_shuffle.subnet](https://registry.terraform.io/providers/hashicorp/random/3.7.1/docs/resources/shuffle) | resource |
| [aws_ami.amazon_linux](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_ebs_volumes"></a> [additional\_ebs\_volumes](#input\_additional\_ebs\_volumes) | List of Map of Additional EBS Volumes | `list(any)` | `[]` | no |
| <a name="input_ami_image_id"></a> [ami\_image\_id](#input\_ami\_image\_id) | ID of AMI to use for the instance | `string` | `""` | no |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | Whether to associate a public IP address with an instance in a VPC | `bool` | `null` | no |
| <a name="input_create_key_pair"></a> [create\_key\_pair](#input\_create\_key\_pair) | Create AWS Key Pair, Set to False if Key already exists in AWS | `bool` | `false` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Create EC2 Security Group, Set to False to Use Existing Security Group | `bool` | `true` | no |
| <a name="input_create_timeout"></a> [create\_timeout](#input\_create\_timeout) | value of the timeout to create the resource | `string` | `"10m"` | no |
| <a name="input_delete_timeout"></a> [delete\_timeout](#input\_delete\_timeout) | value of the timeout to delete the resource | `string` | `"10m"` | no |
| <a name="input_disable_api_termination"></a> [disable\_api\_termination](#input\_disable\_api\_termination) | If true, enables EC2 Instance Termination Protection | `bool` | `false` | no |
| <a name="input_ebs_volume_size"></a> [ebs\_volume\_size](#input\_ebs\_volume\_size) | EBS Volume Size | `number` | `50` | no |
| <a name="input_ebs_volume_type"></a> [ebs\_volume\_type](#input\_ebs\_volume\_type) | EBS Volume Type | `string` | `"gp3"` | no |
| <a name="input_enable_encrypted_volume"></a> [enable\_encrypted\_volume](#input\_enable\_encrypted\_volume) | Enable EBS Volume Encryption | `bool` | `true` | no |
| <a name="input_enable_hibernation_support"></a> [enable\_hibernation\_support](#input\_enable\_hibernation\_support) | If true, the launched EC2 instance will support hibernation | `bool` | `false` | no |
| <a name="input_instance_iam_policies"></a> [instance\_iam\_policies](#input\_instance\_iam\_policies) | Map of Policies to Add to Instance Profile | `map(any)` | `{}` | no |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | Name to be used on EC2 instance created | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Description: The type of instance to start | `string` | `"t3.micro"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Key name of the Key Pair to use for the instance | `string` | `null` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of Existing Security Groups to Use, Ignored if Create Security Group is enabled | `list(string)` | `[]` | no |
| <a name="input_sg_ingress_cidr"></a> [sg\_ingress\_cidr](#input\_sg\_ingress\_cidr) | List of CIDRs to Allow in Security Group, Defaults to the VPC CIDR if ignored. | `list(string)` | `[]` | no |
| <a name="input_sg_ingress_ports"></a> [sg\_ingress\_ports](#input\_sg\_ingress\_ports) | List of Ingress Ports to Allow in Security Group | `list(number)` | <pre>[<br>  80<br>]</pre> | no |
| <a name="input_sg_ingress_protocol"></a> [sg\_ingress\_protocol](#input\_sg\_ingress\_protocol) | Ingress Protocol Name | `string` | `"tcp"` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Name of VPC Subnets to Deploy EC2 | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Compulsory Tags For Terraform Resources, Must Contain Tribe, Squad and Domain | `map(any)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | public ip address |
<!-- End of Document -->