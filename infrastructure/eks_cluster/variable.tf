variable "customer" {
  type        = string
  description = "(Required) Name of Customer. ex: Fiter"
}

variable "environment" {
  type        = string
  description = "(Required) Environment e.g Dev, Stg, Prod"
}

variable "cluster_version" {
  type        = string
  description = "AWS EKS Cluster Version"
  default     = "1.25"
}

variable "common_tags" {
  type        = map(any)
  description = "(Required) Resource Tag"
}

variable "node_groups_attributes" {
  type        = map(any)
  description = "Node Group Properties. Used to Provision EKS node groups"
}

variable "node_security_group_additional_rules" {
  description = "Additional Rules for Node Security Group"

}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the cluster security group will be provisioned"
}
variable "subnets" {
  type        = list(string)
  description = "A list of subnet IDs where the nodes/node groups will be provisioned."
}

variable "aws_auth_users" {
  type        = list(any)
  description = "List of User maps to add to the aws-auth configmap"
  default = []
}

variable "aws_auth_roles" {
  type        = list(any)
  description = "List of role maps to add to the aws-auth configmap"
  default     = []
}

variable "cluster_endpoint_public_access" {
  type        = bool
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled, set to False to enable only private access via VPN"
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
  default     = ["0.0.0.0/0"]
}


variable "eks_logging_bucketname" {
  type        = string
  default     = "eks-logs"
  description = "AWS Bucket Name to Send EKS Logs"
}

variable "assume_role_arn" {
  type        = string
  description = "Terraform Role to Assume"
  default     = ""
}

variable "route_table_ids" {
  type        = list(string)
  description = "Route Table ID for the s3 gateway endpoint if privake only cluster is used"
  default     = []
}

variable "helm_deploy" {
  type        = bool
  description = "Create Helm Deployment User in Cluster"
  default     = false
}

variable "enable_private_zone" {
  description = "Enable Private Route53 Zone"
  type        = bool
  default     = false
}
variable "additional_cluster_policies" {
  type        = map(any)
  description = "Additional Policies to attach to the EKS Cluster"
  default     = {}
}

variable "private_zone_host_name" {
  description = "Private Route53 Zone Host Name"
  type        = string
  default     = "fineract.internal"

}

variable "log_bucket_lifecycle_rules" {
  type = map(object({
    path            = string
    expiration_days = number
  }))
  description = "Number of days to retain the logs in the bucket"
  default = {
    logs = {
      path            = "loki_logs/"
      expiration_days = 90
    }
  }
}

variable "eks_access_entries" {
  type        = map(any)
  description = "Map of EKS Access Entries"
  default     = {}
}

variable "authentication_mode" {
  type        = string
  description = "Authentication Mode for EKS Cluster"
  default     = "API_AND_CONFIG_MAP"
}