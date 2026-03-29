<!-- BEGIN_TF_DOCS -->
# tf-backend

This Terraform module provisions the required resources for configuring a reliable backend. [Terraform Backend Configuration](https://developer.hashicorp.com/terraform/language/backend)

An Amazon S3 bucket is created to securely store the Terraform state file, ensuring high durability and availability.
by multiple users or processes. This setup ensures consistency, security, and efficient collaboration in infrastructure management.

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
# S3 bucket for storing Terraform remote state with versioning,
# AES256 encryption, public access blocked, and private ACL.

data "aws_caller_identity" "current" {}

module "tf_backend" {
  source      = "../"
  bucket_name = "example-customer-terraform-state" # must be globally unique; typically <org>-<env>-terraform-state

  # IAM principals that are allowed full s3:* access to the state bucket.
  # Add the ARN of the role(s) used to run Terraform (e.g. your CI deploy role).
  # Leave empty to skip creating a bucket policy.
  tf_backend_iam_principals = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/example-customer-ghdeploy-role-terraform", # change to your deploy role name
  ]
}
```

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.tf_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.tf_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.tf_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.tf_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.tf_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.tf_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.tf_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The name of the S3 bucket. Must be globally unique. | `string` | n/a | yes |
| <a name="input_tf_backend_iam_principals"></a> [tf\_backend\_iam\_principals](#input\_tf\_backend\_iam\_principals) | AWS IAM principals identifiers | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_terraform_bucket_name"></a> [terraform\_bucket\_name](#output\_terraform\_bucket\_name) | value terraform bucket name |
<!-- END_TF_DOCS -->