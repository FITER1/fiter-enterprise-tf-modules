variable "enable_credential_manager" {
  type        = bool
  default     = true
  description = "Enable Credential Manager"
}

variable "name" {
  type        = string
  description = "Name of the resource"
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

variable "subnets" {
  type        = list(string)
  description = "List of subnets to use for the RDS cluster"
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security group IDs to associate with the RDS cluster"
}

variable "admin_secret_arn" {
  type        = string
  description = "ARN of the admin secret in AWS Secrets Manager"
}

variable "database_host" {
  type        = string
  description = "Host of the database"
}

variable "database_admin_db" {
  type        = string
  description = "Admin database name"
}

variable "database_identifier" {
  type        = string
  description = "Identifier for the database"
}

variable "tags" {
  type        = map(any)
  description = "Tags to apply to the resources"
  default     = {}
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "db_service_users" {
  type = list(object({
    user        = string
    access_type = string
    db_owner    = string
    databases   = list(string)
  }))
  description = "service user to create for application"
  default     = []

  validation {
    condition = alltrue([
      for o in var.db_service_users : contains(["readonly", "readwrite"], o.access_type)
    ])
    error_message = "Access_Type can only contains readonly or readwrite. Kindly check your service Users"
  }

  validation {
    condition = alltrue([
      for o in var.db_service_users : can(regex("^[0-9A-Za-z_]+$", o.user))
    ])
    error_message = "Username should only contain numbers, letters and underscores. Only Alphanumeric values are allowed"
  }

  validation {
    condition = alltrue(flatten([
      for o in var.db_service_users : [
        for db_name in o.databases : can(regex("^[0-9A-Za-z_]+$", db_name))
      ]
    ]))
    error_message = "DB Names should only contain numbers, letters and underscores. Only Alphanumeric values are allowed"
  }
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "docker_image" {
  type        = string
  description = "Docker image to use for the Lambda function"
  default     = null
}

variable "function_source" {
  type        = string
  description = "The source type for the Lambda function (zip or image)"
  validation {
    condition     = var.function_source == "zip" || var.function_source == "image"
    error_message = "function_source must be either 'zip' or 'image'."
  }
}

variable "timeout" {
  type        = number
  description = "Timeout for the Lambda function"
  default     = 120
}

variable "function_code_path" {
  description = "Path to the Lambda function code"
  type        = string
  default     = "lambdas"
}

variable "enable_secretmanager_vpc_endpoint" {
  type        = bool
  description = "Enable VPC Endpoint for Secrets Manager"
  default     = false
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the RDS instance will be deployed"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block of the VPC"
}

variable "database_port" {
  type        = number
  description = "Port number for the database"
  default     = 5432
}
