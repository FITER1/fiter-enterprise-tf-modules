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
  type        = map(any)
  description = "Additional Rules for Node Security Group"
  default     = {}
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the cluster security group will be provisioned"
}
variable "subnets" {
  type        = list(string)
  description = "A list of subnet IDs where the nodes/node groups will be provisioned."
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

variable "assume_role_arn" {
  type        = string
  description = "Terraform Role to Assume"
  default     = ""
}

variable "route_table_ids" {
  type        = list(string)
  description = "Route Table ID for the s3 gateway endpoint if private only cluster is used"
  default     = []
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

variable "eks_access_entries" {
  type        = map(any)
  description = "Map of EKS Access Entries"
  default     = {}
}

variable "disable_api_termination" {
  type        = bool
  description = "If true, enables termination protection on the EKS cluster EC2 instances"
  default     = true
}

variable "authentication_mode" {
  type        = string
  description = "Authentication Mode for EKS Cluster"
  default     = "API_AND_CONFIG_MAP"
}

variable "kms_key_rotation_days" {
  type        = number
  description = "Number of days to rotate the KMS key for EKS managed node group volume encryption"
  default     = 365
}

variable "karpenter_namespace" {
  type        = string
  description = "Namespace for Pod Identity Mapping"
  default     = "karpenter"
}

variable "karpenter_service_account" {
  type        = string
  description = "Service Account for Pod Identity Mapping"
  default     = "karpenter"
}
