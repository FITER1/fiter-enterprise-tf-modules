variable "db_identifier" {
  type        = string
  description = "Name of Database Identifier"
  validation {
    condition     = can(regex("^[0-9A-Za-z-]+$", var.db_identifier))
    error_message = "Username should only contain numbers, letters and underscores. Only Alphanumeric values and - are allowed"
  }
}

variable "engine" {
  type        = string
  description = "The database engine to use"
  default     = "postgres"
  validation {
    condition     = contains(["mysql", "postgres"], var.engine)
    error_message = "Object can Contain the Following postgres or mysql"
  }
}

variable "engine_version" {
  type        = string
  description = "Major engine verison of rds"
  default     = "16"
}

variable "username" {
  type        = string
  description = "Username for the root account of db"
  default     = "postgres"
}

variable "initial_db_name" {
  type        = string
  description = "Name of the db created initially"
  default     = null
}

variable "vpc_id" {
  type        = string
  description = "Vpc to deploy the Cluster"
}

variable "monitoring_interval" {
  type        = number
  description = "Interval of monitoring"
  default     = 0
}

variable "create_monitoring_role" {
  type        = bool
  description = "Flag to create monitoring role"
  default     = false
}

variable "rds_family" {
  type        = string
  description = "RDS family like mysql, aurora with version"
  default     = "postgres16"
}

variable "vpc_availability_zones" {
  type        = list(string)
  description = "List of availability zones in the VPC"
}

variable "db_storage_size" {
  type        = number
  description = "Size of RDS storage in GB"
  default     = 100
}

variable "instance_class" {
  type        = string
  description = "Instance type for the cluster eg. db.t2.large"
}

variable "storage_type" {
  type        = string
  description = "Storage Type"
  default     = "gp3"
}

variable "iops" {
  type        = number
  description = "IOPS to Provision"
  default     = null
}

variable "ca_cert_identifier" {
  type        = string
  default     = "rds-ca-rsa2048-g1"
  description = "See Certificate Authority on RDS Page"
}

variable "rds_db_delete_protection" {
  type        = bool
  description = "Whether aws rds/aurora database should have delete protection enabled"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to the resources"
  default     = {}
}

variable "disable_rds_public_access" {
  type        = bool
  description = "Turn Off Public RDS Access"
  default     = false
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

variable "subnets" {
  type        = list(string)
  description = "List of subnets to use for the RDS cluster"
}

variable "security_group_rules" {
  description = "Security group rules to apply to the RDS cluster"
  default     = {}
}

variable "cluster_instance_override" {
  type        = map(any)
  description = "Instance class for the cluster"
  default     = {}
}

variable "port" {
  type        = number
  description = "Port for the database"
  default     = 5432
}

variable "enabled_cloudwatch_logs_exports" {
  type        = list(string)
  description = "Enabled CloudWatch logs exports"
  default     = ["postgresql"]
}

variable "apply_immediately" {
  type        = bool
  description = "Apply changes immediately"
  default     = true
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Skip final snapshot"
  default     = true
}

variable "cluster_parameter_group" {
  description = "Map of nested arguments for the created DB cluster parameter group"
  type = object({
    name            = optional(string)
    use_name_prefix = optional(bool, true)
    description     = optional(string)
    family          = string
    parameters = optional(list(object({
      name         = string
      value        = string
      apply_method = optional(string, "immediate")
    })))
  })
  default = null
}

variable "security_group_ingress_rules" {
  description = "Map of security group ingress rules to add to the security group created"
  type        = map(any)
  default     = {}
  nullable    = false
}

variable "security_group_egress_rules" {
  description = "Map of security group egress rules to add to the security group created"
  type        = map(any)
  default     = {}
  nullable    = false
}
