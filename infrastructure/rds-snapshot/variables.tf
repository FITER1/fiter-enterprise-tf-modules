variable "rds_family" {
  type        = string
  description = "RDS family like mysql, aurora with version"
  default     = "mysql8.0"
}

variable "major_engine_version" {
  type        = string
  description = "Major engine verison of rds"
  default     = "8.0"
}

variable "username" {
  type        = string
  description = "Username for the root account of db"
  sensitive   = true
}

variable "engine_version" {
  type        = string
  description = "Major engine verison of rds"
  default     = "8.0.33"
}

variable "initial_db_name" {
  type        = string
  description = "Name of the db created initially"
}

variable "db_storage_size" {
  type        = number
  description = "Size of RDS storage in GB"
  default     = "50"
}
variable "instance_class" {
  type        = string
  description = "Instance type for the cluster eg. db.t2.large"
}

variable "rds_db_delete_protection" {
  type        = bool
  description = "Whether aws rds/aurora database should have delete protection enabled"
  default     = true
}

variable "cloudwatch_logs_names" {
  type        = list(string)
  description = "Name of log groups which logs to get"
  default     = ["audit", "error", "general"]
}

variable "maintenance_window" {
  type        = string
  description = "Time at which maintainance should take place"
  default     = "Mon:00:00-Mon:03:00"
}

variable "backup_window" {
  type        = string
  description = "Time duration for backup"
  default     = "03:00-06:00"
}

variable "create_monitoring_role" {
  type        = bool
  description = "Flag to create monitoring role"
  default     = true
}


variable "monitoring_interval" {
  type        = number
  description = "Interval of monitoring"
  default     = 0
}

variable "engine" {
  type        = string
  description = "The database engine to use"
  default     = "mysql"
}

variable "backup_retention_period" {
  type        = number
  description = "Number of Days to store Automated backup"
  default     = 15
}

variable "manage_master_user_password" {
  type        = bool
  description = "Set to true to allow RDS to manage the master user password in Secrets Manager"
  default     = false
}

variable "db_identifier" {
  type        = string
  description = "Name of Database Identifier"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID From VPC Module"
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC CIDR Block to Allow Connections to the Database"
}

variable "rds_subnets" {
  type        = list(string)
  description = "VPC Subnets to Deploy RDS In"
}

variable "intra_subnets" {
  type        = list(string)
  description = "VPC Subnets to Deploy Lambda Non accessible In"
}

variable "disable_rds_public_access" {
  type        = bool
  description = "Turn Off Public RDS Access"
  default     = false
}

variable "snapshot_db_name" {
  type        = string
  description = "Name of DB to be snapshot"
}

variable "allowed_cidrs" {
  type = list(object({
    name        = string
    ip          = string
    description = string
    port        = optional(string, null)
  }))
  description = "Allowed Cidrs in the Database"
  default     = []
}

variable "db_port" {
  type        = number
  description = "Database Port to Use"
  default     = 3306
}

variable "encrypyt_db_storage" {
  type        = bool
  description = "Enable Storage Encryption"
  default     = false
}

variable "storage_type" {
  type        = string
  description = "Storage Type"
  default     = null
}

variable "iops" {
  type        = number
  description = "IOPS to Provision"
  default     = null
}

variable "ca_cert_identifier" {
  type        = string
  description = "See Certificate Authority on RDS Page"
  default     = "rds-ca-rsa2048-g1"
}

variable "performance_insights_enabled" {
  type        = bool
  description = "Enable Performance Insights"
  default     = false
}

variable "performance_insights_retention_period" {
  type        = number
  description = "Performance Insights Retention days"
  default     = 0
}


variable "apply_immediately" {
  type        = bool
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window"
  default     = false
}

variable "cron_schedules" {
  description = "List of cron schedules to create"
  type = list(object({
    name                = string
    schedule_expression = string
    action              = string
    description         = string
  }))

  validation {
    condition = alltrue([
      for schedule in var.cron_schedules : contains(["start", "stop"], schedule.action)
    ])
    error_message = "Action can only be 'start' or 'stop'."
  }
  default = []
}

variable "scheduler_timezone" {
  description = "Timezone for the scheduler"
  type        = string
  default     = "Europe/London"
}

variable "region" {
  description = "Default Region to deploy the resources"
  type        = string
  default     = "eu-west-2"
}
