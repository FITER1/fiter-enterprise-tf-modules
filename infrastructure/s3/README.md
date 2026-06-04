<!-- BEGIN_TF_DOCS -->
Creates an S3 bucket and, when enable\_iam\_writer is true, also creates a dedicated IAM writer user with generated access keys stored in AWS Secrets Manager for object read/write workflows.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |

## Usage
To use this module in your Terraform environment, include it in your Terraform configuration with the necessary parameters. Below is an example of how to use this module:

```hcl
# S3 bucket with versioning enabled (default) and private ACL.

module "app_assets" {
  source = "../"

  bucket_name   = "example-customer-dev-app-assets" # must be globally unique
  create_bucket = true                              # set to false to manage the bucket lifecycle externally

  tags = {
    Name        = "example-customer-dev-app-assets"
    Environment = "dev"
    ManagedBy   = "terraform"
  }

  # bucket_acl        = "private"      # default; change to "public-read" for static site hosting
  # enable_versioning = true           # default; set to false if versioning is not needed
  # force_destroy     = true           # default; set to false to prevent accidental deletion in production
}

module "app_assets_with_writer" {
  source = "../"

  bucket_name       = "example-customer-dev-app-assets-writer"
  create_bucket     = true
  enable_iam_writer = true
  iam_user_tags = {
    Purpose = "upload"
  }

  tags = {
    Name        = "example-customer-dev-app-assets-writer"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | terraform-aws-modules/s3-bucket/aws | ~> 5.13 |
| <a name="module_writer"></a> [writer](#module\_writer) | terraform-aws-modules/iam/aws//modules/iam-user | ~> 6.6 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.writer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_secretsmanager_secret.writer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.writer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_block_public_acls"></a> [block\_public\_acls](#input\_block\_public\_acls) | Whether Amazon S3 should block public ACLs for this bucket. | `bool` | `null` | no |
| <a name="input_block_public_policy"></a> [block\_public\_policy](#input\_block\_public\_policy) | Whether Amazon S3 should block public bucket policies for this bucket. | `bool` | `null` | no |
| <a name="input_bucket_acl"></a> [bucket\_acl](#input\_bucket\_acl) | The canned ACL to apply to the S3 bucket | `string` | `"private"` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The name of the S3 bucket | `string` | n/a | yes |
| <a name="input_bucket_ownership"></a> [bucket\_ownership](#input\_bucket\_ownership) | Whether to control ownership of objects in the bucket | `string` | `"ObjectWriter"` | no |
| <a name="input_control_object_ownership"></a> [control\_object\_ownership](#input\_control\_object\_ownership) | value to control object ownership | `bool` | `true` | no |
| <a name="input_create_bucket"></a> [create\_bucket](#input\_create\_bucket) | Whether to create the S3 bucket | `bool` | `false` | no |
| <a name="input_enable_iam_writer"></a> [enable\_iam\_writer](#input\_enable\_iam\_writer) | Create a dedicated IAM user with object R/W permissions on this bucket; store generated access keys in Secrets Manager. | `bool` | `false` | no |
| <a name="input_enable_versioning"></a> [enable\_versioning](#input\_enable\_versioning) | Whether to enable bucket versioning | `bool` | `true` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error | `bool` | `true` | no |
| <a name="input_iam_policy_name_override"></a> [iam\_policy\_name\_override](#input\_iam\_policy\_name\_override) | Override derived IAM policy name. Renaming an existing policy forces replace. | `string` | `""` | no |
| <a name="input_iam_user_name_override"></a> [iam\_user\_name\_override](#input\_iam\_user\_name\_override) | Override derived IAM user name. IAM user names are unique account-wide. | `string` | `""` | no |
| <a name="input_iam_user_tags"></a> [iam\_user\_tags](#input\_iam\_user\_tags) | Tags merged on top of var.tags for the IAM user only. | `map(string)` | `{}` | no |
| <a name="input_ignore_public_acls"></a> [ignore\_public\_acls](#input\_ignore\_public\_acls) | Whether Amazon S3 should ignore public ACLs for this bucket. | `bool` | `null` | no |
| <a name="input_restrict_public_buckets"></a> [restrict\_public\_buckets](#input\_restrict\_public\_buckets) | Whether Amazon S3 should restrict public bucket policies for this bucket. | `bool` | `null` | no |
| <a name="input_secret_kms_key_id"></a> [secret\_kms\_key\_id](#input\_secret\_kms\_key\_id) | Optional KMS CMK ARN/ID for the Secrets Manager secret. Defaults to AWS-managed aws/secretsmanager. | `string` | `null` | no |
| <a name="input_secret_name_override"></a> [secret\_name\_override](#input\_secret\_name\_override) | Override derived Secrets Manager secret name. | `string` | `""` | no |
| <a name="input_secret_recovery_window_in_days"></a> [secret\_recovery\_window\_in\_days](#input\_secret\_recovery\_window\_in\_days) | Recovery window for the Secrets Manager secret. Set to 0 in dev/test to allow immediate destroy+recreate. | `number` | `7` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to the S3 bucket | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_writer_access_key_id"></a> [iam\_writer\_access\_key\_id](#output\_iam\_writer\_access\_key\_id) | The IAM writer access key ID, when enabled. |
| <a name="output_iam_writer_secret_arn"></a> [iam\_writer\_secret\_arn](#output\_iam\_writer\_secret\_arn) | The Secrets Manager secret ARN containing the IAM writer credentials, when enabled. |
| <a name="output_iam_writer_secret_name"></a> [iam\_writer\_secret\_name](#output\_iam\_writer\_secret\_name) | The Secrets Manager secret name containing the IAM writer credentials, when enabled. |
| <a name="output_iam_writer_user_arn"></a> [iam\_writer\_user\_arn](#output\_iam\_writer\_user\_arn) | The IAM writer user ARN, when enabled. |
| <a name="output_iam_writer_user_name"></a> [iam\_writer\_user\_name](#output\_iam\_writer\_user\_name) | The IAM writer user name, when enabled. |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | The ARN of the S3 bucket. |
| <a name="output_s3_bucket_domain_name"></a> [s3\_bucket\_domain\_name](#output\_s3\_bucket\_domain\_name) | The bucket domain name. |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | The name/id of the S3 bucket. |
<!-- END_TF_DOCS -->