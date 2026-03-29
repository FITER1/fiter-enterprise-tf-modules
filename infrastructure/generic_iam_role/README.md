<!-- DO NOT UPDATE: Document auto-generated! -->
# AWS IAM Role Terraform Module

This module creates a **generic AWS IAM Role** with associated policies.

## Features:
- Creates an IAM role with a formatted name.
- Configures a trust policy to allow role assumption via `principal_type` and `principal_identifiers`.
- Renders and attaches a custom policy from a template.
- Supports tagging with `common_tags`.

## Outputs:
- **`argo_client_arn`**: ARN of the created IAM role.

## Resources:
- IAM Role, IAM Policy, and Role-Policy Attachment.

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
# Generic IAM role with a trust policy and attached managed policy.
# This example creates a role that an EC2 instance can assume,
# with the SSM managed policy attached for Session Manager access.

module "ec2_iam_role" {
  source    = "../"
  role_name = "example-customer-dev-ec2" # change to your role name; "-role" is appended automatically

  common_tags = {
    Name        = "example-customer-dev-ec2-role"
    Environment = "dev"
    ManagedBy   = "terraform"
  }

  # Trust policy — which principal can assume this role
  principal_type        = "Service"
  principal_identifiers = ["ec2.amazonaws.com"] # change to the AWS service or IAM ARN that needs to assume this role

  # Attach existing managed policies by ARN
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", # allows Session Manager access
  ]

  # Optionally attach an inline policy (uncomment and provide a valid JSON policy document)
  # create_policy = true
  # role_policy   = jsonencode({
  #   Version = "2012-10-17"
  #   Statement = [{
  #     Effect   = "Allow"
  #     Action   = ["s3:GetObject"]
  #     Resource = "arn:aws:s3:::example-bucket/*"
  #   }]
  # })
}
```

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.generic_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.generic_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.generic_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assume_policy"></a> [assume\_policy](#input\_assume\_policy) | Assume Policy for the Role | `string` | `null` | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Common Tags to be applied to the IAM Role | `map(any)` | n/a | yes |
| <a name="input_create_policy"></a> [create\_policy](#input\_create\_policy) | Create a Policy for the Role | `bool` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the IAM Role | `string` | `"IAM Role Managed by Terraform"` | no |
| <a name="input_policy_arns"></a> [policy\_arns](#input\_policy\_arns) | A set of policy ARNs to attach to the user | `set(string)` | `[]` | no |
| <a name="input_principal_identifiers"></a> [principal\_identifiers](#input\_principal\_identifiers) | List of Principal Identifiers | `list(string)` | `[]` | no |
| <a name="input_principal_type"></a> [principal\_type](#input\_principal\_type) | Type of Principal | `string` | `"AWS"` | no |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Name of Role Name | `string` | n/a | yes |
| <a name="input_role_policy"></a> [role\_policy](#input\_role\_policy) | The IAM policy to attach to the role | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | Role ARN |
<!-- End of Document -->
<!-- BEGIN_TF_DOCS -->
# AWS IAM Role Terraform Module

This module creates a **generic AWS IAM Role** with associated policies.

## Features:
- Creates an IAM role with a formatted name.
- Configures a trust policy to allow role assumption via `principal_type` and `principal_identifiers`.
- Renders and attaches a custom policy from a template.
- Supports tagging with `common_tags`.

## Outputs:
- **`argo_client_arn`**: ARN of the created IAM role.

## Resources:
- IAM Role, IAM Policy, and Role-Policy Attachment.

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
# Generic IAM role with a trust policy and attached managed policy.
# This example creates a role that an EC2 instance can assume,
# with the SSM managed policy attached for Session Manager access.

module "ec2_iam_role" {
  source    = "../"
  role_name = "example-customer-dev-ec2" # change to your role name; "-role" is appended automatically

  common_tags = {
    Name        = "example-customer-dev-ec2-role"
    Environment = "dev"
    ManagedBy   = "terraform"
  }

  # Trust policy — which principal can assume this role
  principal_type        = "Service"
  principal_identifiers = ["ec2.amazonaws.com"] # change to the AWS service or IAM ARN that needs to assume this role

  # Attach existing managed policies by ARN
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", # allows Session Manager access
  ]

  # Optionally attach an inline policy (uncomment and provide a valid JSON policy document)
  # create_policy = true
  # role_policy   = jsonencode({
  #   Version = "2012-10-17"
  #   Statement = [{
  #     Effect   = "Allow"
  #     Action   = ["s3:GetObject"]
  #     Resource = "arn:aws:s3:::example-bucket/*"
  #   }]
  # })
}
```

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.generic_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.generic_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.generic_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assume_policy"></a> [assume\_policy](#input\_assume\_policy) | Assume Policy for the Role | `string` | `null` | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Common Tags to be applied to the IAM Role | `map(any)` | n/a | yes |
| <a name="input_create_policy"></a> [create\_policy](#input\_create\_policy) | Create a Policy for the Role | `bool` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the IAM Role | `string` | `"IAM Role Managed by Terraform"` | no |
| <a name="input_policy_arns"></a> [policy\_arns](#input\_policy\_arns) | A set of policy ARNs to attach to the user | `set(string)` | `[]` | no |
| <a name="input_principal_identifiers"></a> [principal\_identifiers](#input\_principal\_identifiers) | List of Principal Identifiers | `list(string)` | `[]` | no |
| <a name="input_principal_type"></a> [principal\_type](#input\_principal\_type) | Type of Principal | `string` | `"AWS"` | no |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Name of Role Name | `string` | n/a | yes |
| <a name="input_role_policy"></a> [role\_policy](#input\_role\_policy) | The IAM policy to attach to the role | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | Role ARN |
<!-- END_TF_DOCS -->