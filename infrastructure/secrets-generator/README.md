<!-- DO NOT UPDATE: Document auto-generated! -->
# Secrets Generator Module
This Terraform module is responsible for generating secrets for the infrastructure.
It is designed to be reusable and can be integrated into various parts of the infrastructure
to ensure that secrets are consistently and securely generated.

The module will output the generated secrets which can be used in other parts of your infrastructure.

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
module "secrets" {
  source             = "../../../../terraform-modules/infrastructure/secrets-generator"
  clustername        = "revving-eks-2"
  secret_reader_arns = ["arn:aws:iam::12345678:role/revving-dev-eks-external-secrets"] # allowed secrets readers
  secrets = {
    grafana = {
      passwordLength       = 20
      overridesSpecialChar = false
    }
    application_secret = {}
  }
}
```

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_secrets_manager"></a> [secrets\_manager](#module\_secrets\_manager) | terraform-aws-modules/secrets-manager/aws | ~> 1.3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_clustername"></a> [clustername](#input\_clustername) | Name of Kubernetes Cluster | `string` | n/a | yes |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Common tags to be applied to all resources | `map(any)` | `{}` | no |
| <a name="input_secret_reader_arns"></a> [secret\_reader\_arns](#input\_secret\_reader\_arns) | List of ARNs that can read the secrets | `list(string)` | `[]` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Secrets to be generated | <pre>map(object({<br/>    passwordLength       = optional(number, 32)<br/>    overridesSpecialChar = optional(string, "!#$%&*()-_=+[]{}<>:?")<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_secret"></a> [secret](#output\_secret) | Name of Generated Secret |
| <a name="output_secret_arn"></a> [secret\_arn](#output\_secret\_arn) | ARN of Generated Secret |
<!-- End of Document -->