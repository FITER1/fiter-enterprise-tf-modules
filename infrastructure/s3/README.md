## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.27 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.27 |

## Modules

| Name | Type |
|------|------|
| [s3_bucket](https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest) | resource |

## Resources

No Modules

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [registries\_name](#input\_registries\_name) | (Required) Name of the bucket to be created | `string` | `` | yes |
| <a name="input_create_bucket"></a> [registries\_name](#input\_registries\_name) | (Required) Whether to create a bucket or not | `bool` | `false` | no |
| <a name="input_registries_bucket_acl"></a> [registries\_name](#input\_registries\_name) | Value to indicate the access control for the bucket | `string` | `private` | no |
| <a name="input_registries_tags"></a> [registries\_name](#input\_registries\_name) | (Required) Tags to add to the bucket after created | `map` | `n/a` | yes |
| <a name="input_registries_bucket_ownership"></a> [registries\_name](#input\_registries\_name) | Ownership of items in bucket after creation | `string` | `ObjectWriter` | no |
| <a name="input_registries_control_object_ownership"></a> [registries\_name](#input\_registries\_name) | Value to control object ownership | `bool` | `true` | no |
| <a name="input_registries_force_destroy"></a> [registries\_name](#input\_registries\_name) | If deleting the bucket, destroy everything in it then delete it | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_s3_bucket_arn"></a> [s3\_s3_bucket_arn](#output\_s3\_s3_bucket_arn) | ARN of S3 Bucket |
| <a name="output_s3_bucket_id"></a> [s3\_s3_bucket_arn](#output\_s3\_s3_bucket_id) | S3 Bucket ID |

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

No providers.

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
```

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | terraform-aws-modules/s3-bucket/aws | ~> 5.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_acl"></a> [bucket\_acl](#input\_bucket\_acl) | The canned ACL to apply to the S3 bucket | `string` | `"private"` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The name of the S3 bucket | `string` | n/a | yes |
| <a name="input_bucket_ownership"></a> [bucket\_ownership](#input\_bucket\_ownership) | Whether to control ownership of objects in the bucket | `string` | `"ObjectWriter"` | no |
| <a name="input_control_object_ownership"></a> [control\_object\_ownership](#input\_control\_object\_ownership) | value to control object ownership | `bool` | `true` | no |
| <a name="input_create_bucket"></a> [create\_bucket](#input\_create\_bucket) | Whether to create the S3 bucket | `bool` | `false` | no |
| <a name="input_enable_versioning"></a> [enable\_versioning](#input\_enable\_versioning) | Whether to enable bucket versioning | `bool` | `true` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to the S3 bucket | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | n/a |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | n/a |
<!-- END_TF_DOCS -->