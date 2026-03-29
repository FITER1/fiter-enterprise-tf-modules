<!-- BEGIN_TF_DOCS -->
# RDS Credential Manager
This Terraform configuration defines a module for managing AWS Lambda functions that handle RDS credential management.
Function can be created as a zip file or as a Docker image. The Generated Credentials are stored in AWS Secrets manager
as `${var.environment}/${var.database_identifier}`

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
# RDS Credential Manager — provisions a Lambda function that creates and rotates
# database service users, storing credentials in AWS Secrets Manager.

# --- Dependencies ---

module "vpc" {
  source      = "./../../vpc"
  environment = "dev"
  customer    = "example-customer"
  vpc_cidr    = "10.0.0.0/16"
  common_tags = { Name = "example-customer-dev", Environment = "dev" }
}

module "rds" {
  source = "./../../rds"

  db_identifier  = "example-customer-dev-db"
  environment    = "dev"
  instance_class = "db.t3.medium"

  engine               = "postgres"
  engine_version       = "16.4"
  major_engine_version = "16"
  rds_family           = "postgres16"
  db_port              = 5432
  initial_db_name      = "postgres"

  vpc_id         = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.vpc_cidr_block
  rds_subnets    = module.vpc.private_subnets

  disable_rds_public_access   = true
  manage_master_user_password = true
  storage_type                = "gp3"
}

# --- RDS Credential Manager ---

module "credential_manager" {
  source = "../"

  name        = "example-customer-dev-db-creator" # change to your identifier
  environment = "dev"
  region      = "eu-west-1" # change to your AWS region

  engine = "postgres"

  # Networking — Lambda runs inside the VPC to reach the RDS instance
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = module.vpc.vpc_cidr_block
  subnets            = module.vpc.private_subnets
  security_group_ids = [module.rds.rds_security_group]

  # RDS connection details — wired from RDS module outputs
  admin_secret_arn    = module.rds.db_instance_master_user_secret_arn
  database_host       = module.rds.db_instance_address
  database_admin_db   = "postgres"
  database_identifier = module.rds.db_identifier

  # Lambda source — use "image" for a container image or "zip" for a packaged zip
  function_source = "image"
  docker_image    = "123456789012.dkr.ecr.eu-west-1.amazonaws.com/postgres-db-manager:latest" # change to your ECR image URI

  # Service users to create in the database
  db_service_users = [
    {
      user        = "app_user"  # alphanumeric and underscores only
      access_type = "readwrite" # "readwrite" or "readonly"
      db_owner    = "postgres"  # database role that owns the schemas
      databases   = ["appdb"]   # databases this user should access
    },
    {
      user        = "reporting_user"
      access_type = "readonly"
      db_owner    = "postgres"
      databases   = ["appdb"]
    },
  ]

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_credential_manager"></a> [credential\_manager](#module\_credential\_manager) | terraform-aws-modules/lambda/aws | ~> 8.0 |
| <a name="module_endpoints"></a> [endpoints](#module\_endpoints) | terraform-aws-modules/vpc/aws//modules/vpc-endpoints | ~> 6.0 |
| <a name="module_pymysql_layer"></a> [pymysql\_layer](#module\_pymysql\_layer) | terraform-aws-modules/lambda/aws | ~> 8.0 |

## Resources

| Name | Type |
|------|------|
| [aws_lambda_invocation.db_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_invocation) | resource |
| [aws_lambda_invocation.postgres_init](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_invocation) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.credential_manager_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_secret_arn"></a> [admin\_secret\_arn](#input\_admin\_secret\_arn) | ARN of the admin secret in AWS Secrets Manager | `string` | n/a | yes |
| <a name="input_database_admin_db"></a> [database\_admin\_db](#input\_database\_admin\_db) | Admin database name | `string` | n/a | yes |
| <a name="input_database_host"></a> [database\_host](#input\_database\_host) | Host of the database | `string` | n/a | yes |
| <a name="input_database_identifier"></a> [database\_identifier](#input\_database\_identifier) | Identifier for the database | `string` | n/a | yes |
| <a name="input_database_port"></a> [database\_port](#input\_database\_port) | Port number for the database | `number` | `5432` | no |
| <a name="input_db_service_users"></a> [db\_service\_users](#input\_db\_service\_users) | service user to create for application | <pre>list(object({<br/>    user        = string<br/>    access_type = string<br/>    db_owner    = string<br/>    databases   = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_docker_image"></a> [docker\_image](#input\_docker\_image) | Docker image to use for the Lambda function | `string` | `null` | no |
| <a name="input_enable_credential_manager"></a> [enable\_credential\_manager](#input\_enable\_credential\_manager) | Enable Credential Manager | `bool` | `true` | no |
| <a name="input_enable_secretmanager_vpc_endpoint"></a> [enable\_secretmanager\_vpc\_endpoint](#input\_enable\_secretmanager\_vpc\_endpoint) | Enable VPC Endpoint for Secrets Manager | `bool` | `false` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | The database engine to use | `string` | `"postgres"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | n/a | yes |
| <a name="input_function_code_path"></a> [function\_code\_path](#input\_function\_code\_path) | Path to the Lambda function code | `string` | `"lambdas"` | no |
| <a name="input_function_source"></a> [function\_source](#input\_function\_source) | The source type for the Lambda function (zip or image) | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the resource | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs to associate with the RDS cluster | `list(string)` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | List of subnets to use for the RDS cluster | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resources | `map(any)` | `{}` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Timeout for the Lambda function | `number` | `120` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block of the VPC | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where the RDS instance will be deployed | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->