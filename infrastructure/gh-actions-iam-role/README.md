<!-- DO NOT UPDATE: Document auto-generated! -->
# AWS GITHUB ACTION IAM Terraform Module

This module creates and manages AWS [IAM Roles and Policies](https://aws.amazon.com/iam/) for deployments and CI/CD pipelines.

Resources such as IAM Roles, Policies, and Role-Policy Attachments are created as part of this module. The module supports custom trust and permission policies for CI/CD pipelines and deployment-specific roles.

## Features

- **Deployment Role**: Creates an IAM role for deployments with a customizable trust relationship and associated policies.
- **CI/CD Pipeline Roles**: Creates IAM roles and policies for CI/CD pipelines, supporting GitHub Actions.
- **Policy Management**: Supports the attachment of custom policies to roles.
**/

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
data "aws_caller_identity" "current" {}

module "gh_actions_iam_role" {
  source                   = "../"
  deployment_role_name     = "example_deployment_role_name"
  github_openidconnect_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
  bucket_name              = "example_bucket"
  ci_pipelines_roles       = "example_ci_pipelines_roles"
}


```

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.ci_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.terraform_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.ci_roles](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.terraform_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ci_policies_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.terraform_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ci_pipelines_roles"></a> [ci\_pipelines\_roles](#input\_ci\_pipelines\_roles) | CI Policies to attach | `map(any)` | n/a | yes |
| <a name="input_deployment_role_name"></a> [deployment\_role\_name](#input\_deployment\_role\_name) | The name of the Terraform IAM deployment role | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_github_iam_role_arn"></a> [github\_iam\_role\_arn](#output\_github\_iam\_role\_arn) | github iam role arn |
| <a name="output_terraform_role_arn"></a> [terraform\_role\_arn](#output\_terraform\_role\_arn) | terraform role arn |
<!-- End of Document -->
<!-- BEGIN_TF_DOCS -->
# AWS GITHUB ACTION IAM Terraform Module

This module creates and manages AWS [IAM Roles and Policies](https://aws.amazon.com/iam/) for deployments and CI/CD pipelines.

Resources such as IAM Roles, Policies, and Role-Policy Attachments are created as part of this module. The module supports custom trust and permission policies for CI/CD pipelines and deployment-specific roles.

## Features

- **Deployment Role**: Creates an IAM role for deployments with a customizable trust relationship and associated policies.
- **CI/CD Pipeline Roles**: Creates IAM roles and policies for CI/CD pipelines, supporting GitHub Actions.
- **Policy Management**: Supports the attachment of custom policies to roles.
**/

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
# IAM role for Terraform deployments, plus optional per-pipeline CI/CD roles.
# The deployment role trusts the account root and gets a broad policy covering
# the services Terraform needs to manage (EC2, RDS, EKS, S3, IAM, etc.).

module "gh_actions_iam_role" {
  source = "../"

  deployment_role_name = "example-customer" # change to your project/customer name; roles are named <name>-terraform

  # create_admin_role = true (default) — creates the <deployment_role_name>-terraform role.
  # Set to false if you only want to create the ci_pipelines_roles below.

  # Optional: create per-pipeline CI/CD roles using OIDC trust policies.
  # Each entry requires two policy files checked into your repo:
  #   trustjson:      path (relative to the module root) to an IAM trust policy JSON template
  #   permissionfile: path to an IAM permissions policy JSON template
  #   envvars:        optional map of variables expanded inside the template files via templatefile()
  #
  # ci_pipelines_roles = {
  #   deploy = {
  #     trustjson      = "policies/github-oidc-trust.json"
  #     permissionfile = "policies/deploy-permissions.json"
  #     envvars        = {
  #       account_id = "123456789012"  # change to your AWS account ID
  #       repo       = "example-org/example-repo"
  #     }
  #   }
  # }
}
```

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.ci_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.terraform_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.ci_roles](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.terraform_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ci_policies_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.terraform_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ci_pipelines_roles"></a> [ci\_pipelines\_roles](#input\_ci\_pipelines\_roles) | CI Policies to attach | `map(any)` | `{}` | no |
| <a name="input_create_admin_role"></a> [create\_admin\_role](#input\_create\_admin\_role) | Whether to create an admin role for the deployment role | `bool` | `true` | no |
| <a name="input_deployment_role_name"></a> [deployment\_role\_name](#input\_deployment\_role\_name) | The name of the Terraform IAM deployment role | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ci_pipeline_roles"></a> [ci\_pipeline\_roles](#output\_ci\_pipeline\_roles) | CI pipeline roles |
| <a name="output_terraform_role_arn"></a> [terraform\_role\_arn](#output\_terraform\_role\_arn) | terraform role arn |
<!-- END_TF_DOCS -->