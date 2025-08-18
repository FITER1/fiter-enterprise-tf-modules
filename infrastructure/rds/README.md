<!-- DO NOT UPDATE: Document auto-generated! -->
# AWS RDS Terraform Module

This module provisions an AWS [RDS Database Instance](https://aws.amazon.com/rds/) along with supporting resources such as Security Groups, Read Replicas, and IAM Lambda integration.

Resources created include:
- RDS instances with customizable configurations.
- Security Groups with ingress and egress rules.
- Read Replicas to enhance performance.
- Lambda functions for credential management and database initialization.
- IAM roles and policies for secure access.

The module ensures seamless database access through integration with AWS Secrets Manager and Session Manager for secure credential storage and retrieval.

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
# Generic RDS
module "rds" {
  source                                 = "../"
  db_identifier                          = "mydb1"                                # Unique identifier for the RDS instance
  username                               = "admin"                                # Hardcoded username
  vpc_id                                 = "vpc-12345678"                         # Hardcoded VPC ID
  vpc_cidr_block                         = "10.0.0.0/16"                          # Hardcoded VPC CIDR block
  rds_subnets                            = ["subnet-11111111", "subnet-22222222"] # Hardcoded RDS subnets
  initial_db_name                        = "exampledb"                            # Hardcoded initial database name
  instance_class                         = "db.t3.medium"                         # Instance type
  intra_subnets                          = ["subnet-33333333", "subnet-44444444"] # Hardcoded intra subnets
  db_service_users                       = ["service-user-1", "service-user-2"]   # Hardcoded RDS service users
  disable_rds_public_access              = true                                   # Disable public access to RDS
  allowed_cidrs                          = ["192.168.1.0/24", "10.0.0.0/16"]      # Allowed CIDR ranges
  rds_db_delete_protection               = true                                   # Enable deletion protection
  engine_version                         = "8.0"                                  # Engine version for MySQL
  major_engine_version                   = "8"                                    # Major engine version for MySQL
  engine                                 = "mysql"                                # Database engine
  rds_family                             = "mysql8.0"                             # RDS family for MySQL
  cloudwatch_logs_names                  = ["error", "general", "slowquery"]      # CloudWatch log group names
  db_port                                = 3306                                   # Database port for MySQL
  db_storage_size                        = 100                                    # Storage size in GB
  cloudwatch_log_group_retention_in_days = 14                                     # Retention period for CloudWatch logs
  create_cloudwatch_log_group            = true                                   # Whether to create CloudWatch log group
  encrypyt_db_storage                    = true                                   # Encrypt DB storage
  region                                 = "eu-west-1"                            # AWS region]
  environment                            = "dev"                                  # Environment
}

# RDS From Snapshot
module "rds-snapshot" {
  source                    = "../"
  db_identifier             = "mydb1"
  username                  = "admin"
  snapshot_name             = "mydb-snapshot" # <======= snapshot identifier
  vpc_id                    = "vpc-12345678"
  vpc_cidr_block            = "10.0.0.0/16"
  rds_subnets               = ["subnet-11111111", "subnet-22222222"]
  initial_db_name           = "exampledb"
  instance_class            = "db.t3.medium"
  intra_subnets             = ["subnet-33333333", "subnet-44444444"]
  db_service_users          = ["service-user-1", "service-user-2"]
  disable_rds_public_access = true
  # ...
}

# RDS With Read Replica
module "rds-replicas" {
  source                    = "../"
  db_identifier             = "mydb1"
  username                  = "admin"
  replicate_source_db       = module.rds.db_identifier # <======= source db identifier
  vpc_id                    = "vpc-12345678"
  vpc_cidr_block            = "10.0.0.0/16"
  rds_subnets               = ["subnet-11111111", "subnet-22222222"]
  initial_db_name           = "exampledb"
  instance_class            = "db.t3.medium"
  intra_subnets             = ["subnet-33333333", "subnet-44444444"]
  db_service_users          = ["service-user-1", "service-user-2"]
  disable_rds_public_access = true
  allowed_cidrs             = ["192.168.1.0/24", "10.0.0.0/16"]
  # ...
}
```

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_db"></a> [db](#module\_db) | terraform-aws-modules/rds/aws | ~> 6.12.0 |
| <a name="module_eventbridge_scaler"></a> [eventbridge\_scaler](#module\_eventbridge\_scaler) | terraform-aws-modules/eventbridge/aws | ~> 3.17.0 |
| <a name="module_eventbridge_scheduler_role"></a> [eventbridge\_scheduler\_role](#module\_eventbridge\_scheduler\_role) | git::git@bitbucket.org:revvingadmin/terraform-modules.git//infrastructure//generic_iam_role | 1.4.0 |

## Resources

| Name | Type |
|------|------|
| [aws_security_group.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.access_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.vpc_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.ssm_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_cidrs"></a> [allowed\_cidrs](#input\_allowed\_cidrs) | Allowed Cidrs in the Database | <pre>list(object({<br/>    name        = string<br/>    ip          = string<br/>    description = string<br/>    port        = optional(string, null)<br/>  }))</pre> | `[]` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Specifies whether any database modifications are applied immediately, or during the next maintenance window | `bool` | `false` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | Number of Days to store Automated backup | `number` | `15` | no |
| <a name="input_backup_window"></a> [backup\_window](#input\_backup\_window) | Time duration for backup | `string` | `"03:00-06:00"` | no |
| <a name="input_ca_cert_identifier"></a> [ca\_cert\_identifier](#input\_ca\_cert\_identifier) | See Certificate Authority on RDS Page | `string` | `"rds-ca-rsa2048-g1"` | no |
| <a name="input_cloudwatch_log_group_retention_in_days"></a> [cloudwatch\_log\_group\_retention\_in\_days](#input\_cloudwatch\_log\_group\_retention\_in\_days) | The number of days to retain CloudWatch logs for the DB instance | `number` | `7` | no |
| <a name="input_cloudwatch_logs_names"></a> [cloudwatch\_logs\_names](#input\_cloudwatch\_logs\_names) | Name of log groups which logs to get | `list` | <pre>[<br/>  "audit",<br/>  "error",<br/>  "general"<br/>]</pre> | no |
| <a name="input_create_cloudwatch_log_group"></a> [create\_cloudwatch\_log\_group](#input\_create\_cloudwatch\_log\_group) | Determines whether a CloudWatch log group is created for each enabled\_cloudwatch\_logs\_exports | `bool` | `false` | no |
| <a name="input_create_monitoring_role"></a> [create\_monitoring\_role](#input\_create\_monitoring\_role) | Flag to create monitoring role | `bool` | `false` | no |
| <a name="input_cron_schedules"></a> [cron\_schedules](#input\_cron\_schedules) | List of cron schedules to create | <pre>list(object({<br/>    name                = string<br/>    schedule_expression = string<br/>    action              = string<br/>    description         = string<br/>  }))</pre> | `[]` | no |
| <a name="input_db_identifier"></a> [db\_identifier](#input\_db\_identifier) | Name of Database Identifier | `string` | n/a | yes |
| <a name="input_db_port"></a> [db\_port](#input\_db\_port) | Database Port to Use | `number` | `3306` | no |
| <a name="input_db_storage_size"></a> [db\_storage\_size](#input\_db\_storage\_size) | Size of RDS storage in GB | `number` | `"50"` | no |
| <a name="input_disable_rds_public_access"></a> [disable\_rds\_public\_access](#input\_disable\_rds\_public\_access) | Turn Off Public RDS Access | `bool` | `false` | no |
| <a name="input_enable_multi_az"></a> [enable\_multi\_az](#input\_enable\_multi\_az) | Enable Multi-AZ Cluster | `bool` | `false` | no |
| <a name="input_encrypt_db_storage"></a> [encrypt\_db\_storage](#input\_encrypt\_db\_storage) | Enable Storage Encryption | `bool` | `true` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | The database engine to use | `string` | `"mysql"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Major engine verison of rds | `string` | `"8.0.23"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment to deploy the resources | `string` | `null` | no |
| <a name="input_initial_db_name"></a> [initial\_db\_name](#input\_initial\_db\_name) | Name of the db created initially | `string` | `null` | no |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | Instance type for the cluster eg. db.t2.large | `string` | n/a | yes |
| <a name="input_iops"></a> [iops](#input\_iops) | IOPS to Provision | `number` | `null` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Time at which maintainance should take place | `string` | `"Mon:00:00-Mon:03:00"` | no |
| <a name="input_major_engine_version"></a> [major\_engine\_version](#input\_major\_engine\_version) | Major engine verison of rds | `string` | `"8.0"` | no |
| <a name="input_manage_master_user_password"></a> [manage\_master\_user\_password](#input\_manage\_master\_user\_password) | Set to true to allow RDS to manage the master user password in Secrets Manager | `bool` | `true` | no |
| <a name="input_monitoring_interval"></a> [monitoring\_interval](#input\_monitoring\_interval) | Interval of monitoring | `number` | `0` | no |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | Enable Performance Insights | `bool` | `false` | no |
| <a name="input_performance_insights_retention_period"></a> [performance\_insights\_retention\_period](#input\_performance\_insights\_retention\_period) | Performance Insights Retention days | `number` | `0` | no |
| <a name="input_rds_db_delete_protection"></a> [rds\_db\_delete\_protection](#input\_rds\_db\_delete\_protection) | Whether aws rds/aurora database should have delete protection enabled | `bool` | `true` | no |
| <a name="input_rds_family"></a> [rds\_family](#input\_rds\_family) | RDS family like mysql, aurora with version | `string` | `"mysql8.0"` | no |
| <a name="input_rds_subnets"></a> [rds\_subnets](#input\_rds\_subnets) | VPC Subnets to Deploy RDS In | `list(string)` | n/a | yes |
| <a name="input_read_replica"></a> [read\_replica](#input\_read\_replica) | Enable Read Replicas for Database | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | Region to deploy the resources | `string` | `"eu-west-2"` | no |
| <a name="input_replicate_source_db"></a> [replicate\_source\_db](#input\_replicate\_source\_db) | Specifies that this resource is a Replicate database, and to use this value as the source database. This correlates to the identifier of another Amazon RDS Database to replicate | `string` | `null` | no |
| <a name="input_scheduler_timezone"></a> [scheduler\_timezone](#input\_scheduler\_timezone) | Timezone for the scheduler | `string` | `"Europe/London"` | no |
| <a name="input_snapshot_name"></a> [snapshot\_name](#input\_snapshot\_name) | Name of DB to be snapshot | `string` | `null` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | Storage Type | `string` | `null` | no |
| <a name="input_username"></a> [username](#input\_username) | Username for the root account of db | `string` | `null` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | VPC CIDR Block to Allow Connections to the Database | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID From VPC Module | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_identifier"></a> [db\_identifier](#output\_db\_identifier) | Identifier for the database |
| <a name="output_db_instance_address"></a> [db\_instance\_address](#output\_db\_instance\_address) | value of the RDS instance address |
| <a name="output_db_instance_master_user_secret_arn"></a> [db\_instance\_master\_user\_secret\_arn](#output\_db\_instance\_master\_user\_secret\_arn) | ARN of the master user secret in AWS Secrets Manager |
| <a name="output_rds_security_group"></a> [rds\_security\_group](#output\_rds\_security\_group) | value of the RDS security group |
<!-- End of Document -->