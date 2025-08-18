<!-- DO NOT UPDATE: Document auto-generated! -->
# AWS RDS Terraform Module

This module provisions an RDS instance from a snapshot and manages related resources such as security groups, ingress, and egress rules.

## Features
- Creates an RDS instance using the AWS RDS module.
- Manages an RDS DB snapshot.
- Provisions and configures security groups, including ingress and egress rules.
- Configurable through input variables to adapt to different environments.

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
module "develop" {
  source                      = "../"
  vpc_id                      = "vpc-12345678"                         # Replace with your actual VPC ID
  vpc_cidr_block              = "10.0.0.0/16"                          # VPC CIDR block
  rds_subnets                 = ["subnet-12345678", "subnet-87654321"] # List of RDS subnets (private)
  instance_class              = "db.t3.small"
  intra_subnets               = ["subnet-23456789", "subnet-98765432"] # List of intra subnets
  disable_rds_public_access   = true
  engine_version              = "13"
  major_engine_version        = "13"
  engine                      = "postgres"
  rds_family                  = "postgres13"
  cloudwatch_logs_names       = ["postgresql", "upgrade"] # specific to postgres
  storage_type                = "io1"
  iops                        = 1000
  db_identifier               = "develop"
  db_storage_size             = "100"
  snapshot_db_name            = "example_snapshot"
  username                    = "example_username"
  initial_db_name             = null
  manage_master_user_password = false
  db_port                     = 5432
  encrypyt_db_storage         = true
  rds_db_delete_protection    = false
  apply_immediately           = false

  allowed_cidrs = [
    {
      "name" : "general-ingress"
      "ip" : "0.0.0.0/0",
      "description" : "Grant Access"
    }
  ]
  depends_on = [module.vpc]
}
```

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_db"></a> [db](#module\_db) | terraform-aws-modules/rds/aws | ~> 6.12.0 |
| <a name="module_eventbridge_scaler"></a> [eventbridge\_scaler](#module\_eventbridge\_scaler) | terraform-aws-modules/eventbridge/aws | ~> 3.17.0 |
| <a name="module_eventbridge_scheduler_role"></a> [eventbridge\_scheduler\_role](#module\_eventbridge\_scheduler\_role) | ../generic_iam_role | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_db_snapshot.db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_snapshot) | resource |
| [aws_security_group.service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.access_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.vpc_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_iam_policy_document.ssm_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_cidrs"></a> [allowed\_cidrs](#input\_allowed\_cidrs) | Allowed Cidrs in the Database | <pre>list(object({<br/>    name        = string<br/>    ip          = string<br/>    description = string<br/>    port        = optional(string, null)<br/>  }))</pre> | `[]` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Specifies whether any database modifications are applied immediately, or during the next maintenance window | `bool` | `false` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | Number of Days to store Automated backup | `number` | `15` | no |
| <a name="input_backup_window"></a> [backup\_window](#input\_backup\_window) | Time duration for backup | `string` | `"03:00-06:00"` | no |
| <a name="input_ca_cert_identifier"></a> [ca\_cert\_identifier](#input\_ca\_cert\_identifier) | See Certificate Authority on RDS Page | `string` | `"rds-ca-rsa2048-g1"` | no |
| <a name="input_cloudwatch_logs_names"></a> [cloudwatch\_logs\_names](#input\_cloudwatch\_logs\_names) | Name of log groups which logs to get | `list(string)` | <pre>[<br/>  "audit",<br/>  "error",<br/>  "general"<br/>]</pre> | no |
| <a name="input_create_monitoring_role"></a> [create\_monitoring\_role](#input\_create\_monitoring\_role) | Flag to create monitoring role | `bool` | `true` | no |
| <a name="input_cron_schedules"></a> [cron\_schedules](#input\_cron\_schedules) | List of cron schedules to create | <pre>list(object({<br/>    name                = string<br/>    schedule_expression = string<br/>    action              = string<br/>    description         = string<br/>  }))</pre> | `[]` | no |
| <a name="input_db_identifier"></a> [db\_identifier](#input\_db\_identifier) | Name of Database Identifier | `string` | n/a | yes |
| <a name="input_db_port"></a> [db\_port](#input\_db\_port) | Database Port to Use | `number` | `3306` | no |
| <a name="input_db_storage_size"></a> [db\_storage\_size](#input\_db\_storage\_size) | Size of RDS storage in GB | `number` | `"50"` | no |
| <a name="input_disable_rds_public_access"></a> [disable\_rds\_public\_access](#input\_disable\_rds\_public\_access) | Turn Off Public RDS Access | `bool` | `false` | no |
| <a name="input_encrypyt_db_storage"></a> [encrypyt\_db\_storage](#input\_encrypyt\_db\_storage) | Enable Storage Encryption | `bool` | `false` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | The database engine to use | `string` | `"mysql"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Major engine verison of rds | `string` | `"8.0.33"` | no |
| <a name="input_initial_db_name"></a> [initial\_db\_name](#input\_initial\_db\_name) | Name of the db created initially | `string` | n/a | yes |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | Instance type for the cluster eg. db.t2.large | `string` | n/a | yes |
| <a name="input_intra_subnets"></a> [intra\_subnets](#input\_intra\_subnets) | VPC Subnets to Deploy Lambda Non accessible In | `list(string)` | n/a | yes |
| <a name="input_iops"></a> [iops](#input\_iops) | IOPS to Provision | `number` | `null` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Time at which maintainance should take place | `string` | `"Mon:00:00-Mon:03:00"` | no |
| <a name="input_major_engine_version"></a> [major\_engine\_version](#input\_major\_engine\_version) | Major engine verison of rds | `string` | `"8.0"` | no |
| <a name="input_manage_master_user_password"></a> [manage\_master\_user\_password](#input\_manage\_master\_user\_password) | Set to true to allow RDS to manage the master user password in Secrets Manager | `bool` | `false` | no |
| <a name="input_monitoring_interval"></a> [monitoring\_interval](#input\_monitoring\_interval) | Interval of monitoring | `number` | `0` | no |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | Enable Performance Insights | `bool` | `false` | no |
| <a name="input_performance_insights_retention_period"></a> [performance\_insights\_retention\_period](#input\_performance\_insights\_retention\_period) | Performance Insights Retention days | `number` | `0` | no |
| <a name="input_rds_db_delete_protection"></a> [rds\_db\_delete\_protection](#input\_rds\_db\_delete\_protection) | Whether aws rds/aurora database should have delete protection enabled | `bool` | `true` | no |
| <a name="input_rds_family"></a> [rds\_family](#input\_rds\_family) | RDS family like mysql, aurora with version | `string` | `"mysql8.0"` | no |
| <a name="input_rds_subnets"></a> [rds\_subnets](#input\_rds\_subnets) | VPC Subnets to Deploy RDS In | `list(string)` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Default Region to deploy the resources | `string` | `"eu-west-2"` | no |
| <a name="input_scheduler_timezone"></a> [scheduler\_timezone](#input\_scheduler\_timezone) | Timezone for the scheduler | `string` | `"Europe/London"` | no |
| <a name="input_snapshot_db_name"></a> [snapshot\_db\_name](#input\_snapshot\_db\_name) | Name of DB to be snapshot | `string` | n/a | yes |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | Storage Type | `string` | `null` | no |
| <a name="input_username"></a> [username](#input\_username) | Username for the root account of db | `string` | n/a | yes |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | VPC CIDR Block to Allow Connections to the Database | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID From VPC Module | `string` | n/a | yes |

## Outputs

No outputs.
<!-- End of Document -->