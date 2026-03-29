<!-- DO NOT UPDATE: Document auto-generated! -->
# AWS ECR Terraform Module

This module provisions multiple [Amazon Elastic Container Registry (ECR)](https://aws.amazon.com/ecr/) repositories on AWS.

Features of this module:
- **ECR Repositories**: Automatically creates repositories for each name provided in the `registries_name` variable.
- **Encryption**: Each repository is configured with AES256 encryption to ensure secure storage of container images.
- **Image Scanning**: Image scanning is disabled by default (`scan_on_push = false`) but can be customized based on requirements.

This module ensures security, scalability, and easy management of container image repositories for your workloads.

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
module "ecr" {
  source          = "../"
  registries_name = ["sample-registry"]
}
```

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecr_repository.ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_registries_name"></a> [registries\_name](#input\_registries\_name) | (Required) List of ECR Registries to be created | `list(string)` | `[]` | no |

## Outputs

No outputs.
<!-- End of Document -->