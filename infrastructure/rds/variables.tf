variable "rds_family" {
  description = "RDS family like mysql, aurora with version"
  default     = "mysql8.0"
}

variable "major_engine_version" {
  description = "Major engine verison of rds"
  default     = "8.0"
  type        = string
}

variable "username" {
  description = "Username for the root account of db"
  sensitive   = true
}

variable "engine_version" {
  description = "Major engine verison of rds"
  default     = "8.0.23"
  type        = string
}

variable "initial_db_name" {
  description = "Name of the db created initially"
  type        = string
}

variable "db_storage_size" {
  description = "Size of RDS storage in GB"
  default     = "50"
  type        = number
}
variable "instance_class" {
  description = "Instance type for the cluster eg. db.t2.large"
  type        = string
}

variable "rds_db_delete_protection" {
  type        = bool
  description = "Whether aws rds/aurora database should have delete protection enabled"
  default     = true
}

variable "cloudwatch_logs_names" {
  description = "Name of log groups which logs to get"
  default     = ["audit", "error", "general"]
}

variable "maintenance_window" {
  description = "Time at which maintainance should take place"
  default     = "Mon:00:00-Mon:03:00"
  type        = string
}

variable "backup_window" {
  description = "Time duration for backup"
  default     = "03:00-06:00"
}

variable "create_monitoring_role" {
  description = "Flag to create monitoring role"
  default     = false
  type        = bool
}


variable "monitoring_interval" {
  description = "Interval of monitoring"
  type        = number
  default     = 0
}

variable "engine" {
  description = "The database engine to use"
  default     = "mysql"
}

variable "backup_retention_period" {
  type        = number
  default     = 15
  description = "Number of Days to store Automated backup"
}

variable "manage_master_user_password" {
  description = "Set to true to allow RDS to manage the master user password in Secrets Manager"
  default     = true
  type        = bool
}

variable "db_identifier" {
  type        = string
  description = "Name of Database Identifier"
}

variable "vpc_id" {
  description = "VPC ID From VPC Module"
  type        = string
}

variable "vpc_cidr_block" {
  description = "VPC CIDR Block to Allow Connections to the Database"
  type        = string
}

variable "rds_subnets" {
  description = "VPC Subnets to Deploy RDS In"
  type        = list(string)
}

variable "intra_subnets" {
  description = "VPC Subnets to Deploy Lambda Non accessible In"
  type        = list(string)
}

variable "db_service_users" {
  description = "service user to create for application"
  type        = list(string)
}

variable "disable_rds_public_access" {
  description = "Turn Off Public RDS Access"
  type        = bool
  default     = false
}

variable "parameters" {
  description = "List of Optional Parameters to Add to RDS"
  type = list(object({
    name  = string
    value = string
  }))
}

variable "max_allocated_storage" {
  description = "Specifies the value for Storage Autoscaling"
  type        = number
  default     = 0
}

variable "deletion_protection" {
  description = "Deletion Protection for Database"
  type        = bool
  default     = false
}
