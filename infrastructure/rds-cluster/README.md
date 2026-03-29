<!-- BEGIN_TF_DOCS -->


## Requirements

No requirements.

## Providers

No providers.

## Usage
To use this module in your Terraform environment, include it in your Terraform configuration with the necessary parameters. Below is an example of how to use this module:

```hcl
# Aurora PostgreSQL-compatible RDS cluster with a single writer instance.

# --- Dependencies ---

module "vpc" {
  source      = "./../../vpc"
  environment = "dev"
  customer    = "example-customer"
  vpc_cidr    = "10.0.0.0/16"
  common_tags = { Name = "example-customer-dev", Environment = "dev" }
}

# --- RDS Cluster ---

module "rds_cluster" {
  source = "../"

  db_identifier   = "example-customer-dev-db" # alphanumeric and hyphens only
  username        = "postgres"                # change to your preferred admin username
  initial_db_name = "appdb"

  # Engine
  engine         = "postgres"
  engine_version = "16"
  rds_family     = "postgres16"

  # Sizing
  instance_class  = "db.t3.medium" # right-size for your workload
  db_storage_size = 50

  # Networking
  vpc_id                 = module.vpc.vpc_id
  subnets                = module.vpc.private_subnets
  vpc_availability_zones = ["eu-west-1a", "eu-west-1b"] # change to AZs in your region

  disable_rds_public_access = true
  skip_final_snapshot       = true # set to false in production to retain a final snapshot on destroy

  tags = {
    Name        = "example-customer-dev-db"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aurora"></a> [aurora](#module\_aurora) | terraform-aws-modules/rds-aurora/aws | ~> 10.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_cidrs"></a> [allowed\_cidrs](#input\_allowed\_cidrs) | Allowed Cidrs in the Database | <pre>list(object({<br/>    name        = string<br/>    ip          = string<br/>    description = string<br/>    port        = optional(string, null)<br/>  }))</pre> | `[]` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Apply changes immediately | `bool` | `true` | no |
| <a name="input_ca_cert_identifier"></a> [ca\_cert\_identifier](#input\_ca\_cert\_identifier) | See Certificate Authority on RDS Page | `string` | `"rds-ca-rsa2048-g1"` | no |
| <a name="input_cluster_instance_override"></a> [cluster\_instance\_override](#input\_cluster\_instance\_override) | Instance class for the cluster | `map(any)` | `{}` | no |
| <a name="input_cluster_parameter_group"></a> [cluster\_parameter\_group](#input\_cluster\_parameter\_group) | Map of nested arguments for the created DB cluster parameter group | <pre>object({<br/>    name            = optional(string)<br/>    use_name_prefix = optional(bool, true)<br/>    description     = optional(string)<br/>    family          = string<br/>    parameters = optional(list(object({<br/>      name         = string<br/>      value        = string<br/>      apply_method = optional(string, "immediate")<br/>    })))<br/>  })</pre> | `null` | no |
| <a name="input_create_monitoring_role"></a> [create\_monitoring\_role](#input\_create\_monitoring\_role) | Flag to create monitoring role | `bool` | `false` | no |
| <a name="input_db_identifier"></a> [db\_identifier](#input\_db\_identifier) | Name of Database Identifier | `string` | n/a | yes |
| <a name="input_db_storage_size"></a> [db\_storage\_size](#input\_db\_storage\_size) | Size of RDS storage in GB | `number` | `100` | no |
| <a name="input_disable_rds_public_access"></a> [disable\_rds\_public\_access](#input\_disable\_rds\_public\_access) | Turn Off Public RDS Access | `bool` | `false` | no |
| <a name="input_enabled_cloudwatch_logs_exports"></a> [enabled\_cloudwatch\_logs\_exports](#input\_enabled\_cloudwatch\_logs\_exports) | Enabled CloudWatch logs exports | `list(string)` | <pre>[<br/>  "postgresql"<br/>]</pre> | no |
| <a name="input_engine"></a> [engine](#input\_engine) | The database engine to use | `string` | `"postgres"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Major engine verison of rds | `string` | `"16"` | no |
| <a name="input_initial_db_name"></a> [initial\_db\_name](#input\_initial\_db\_name) | Name of the db created initially | `string` | `null` | no |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | Instance type for the cluster eg. db.t2.large | `string` | n/a | yes |
| <a name="input_iops"></a> [iops](#input\_iops) | IOPS to Provision | `number` | `null` | no |
| <a name="input_monitoring_interval"></a> [monitoring\_interval](#input\_monitoring\_interval) | Interval of monitoring | `number` | `0` | no |
| <a name="input_port"></a> [port](#input\_port) | Port for the database | `number` | `5432` | no |
| <a name="input_rds_db_delete_protection"></a> [rds\_db\_delete\_protection](#input\_rds\_db\_delete\_protection) | Whether aws rds/aurora database should have delete protection enabled | `bool` | `true` | no |
| <a name="input_rds_family"></a> [rds\_family](#input\_rds\_family) | RDS family like mysql, aurora with version | `string` | `"postgres16"` | no |
| <a name="input_security_group_egress_rules"></a> [security\_group\_egress\_rules](#input\_security\_group\_egress\_rules) | Map of security group egress rules to add to the security group created | `map(any)` | `{}` | no |
| <a name="input_security_group_ingress_rules"></a> [security\_group\_ingress\_rules](#input\_security\_group\_ingress\_rules) | Map of security group ingress rules to add to the security group created | `map(any)` | `{}` | no |
| <a name="input_security_group_rules"></a> [security\_group\_rules](#input\_security\_group\_rules) | Security group rules to apply to the RDS cluster | `map` | `{}` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Skip final snapshot | `bool` | `true` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | Storage Type | `string` | `"gp3"` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | List of subnets to use for the RDS cluster | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to the resources | `map(string)` | `{}` | no |
| <a name="input_username"></a> [username](#input\_username) | Username for the root account of db | `string` | `"postgres"` | no |
| <a name="input_vpc_availability_zones"></a> [vpc\_availability\_zones](#input\_vpc\_availability\_zones) | List of availability zones in the VPC | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | Vpc to deploy the Cluster | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_secret_arn"></a> [admin\_secret\_arn](#output\_admin\_secret\_arn) | ARN of the admin secret in AWS Secrets Manager |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Cluster endpoint for the RDS cluster |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Security group ID for the RDS cluster |
<!-- END_TF_DOCS -->