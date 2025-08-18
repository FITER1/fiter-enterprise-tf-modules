variable "customer" {
  type        = string
  description = "(Required) Name of Customer. ex: Fiter"
}

variable "environment" {
  type        = string
  description = "(Required) Environment e.g Dev, Stg, Prod"
}

variable "vpc_cidr" {
  type        = string
  description = "(Required) VPC Cidr"
}

variable "common_tags" {
  type        = map(any)
  description = "(Required) Resource Tag"
}

variable "enable_nat_gateway" {
  type        = bool
  description = "(Optional) Should be true if you want to provision NAT Gateways for each of your private networks"
  default     = true
}

variable "single_nat_gateway" {
  type        = bool
  description = "(Optional) Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  default     = true
}

variable "enable_karpenter_autoscaler" {
  type        = bool
  description = "Enabled Karpenter Autoscaler"
  default     = true
}

variable "enable_network_endpoints" {
  type        = bool
  description = "Enable VPC Endpoints for the cluster"
  default     = false
}

variable "vpc_interface_endpoints" {
  type        = list(string)
  description = "List of Services to create VPC interface Endpoints. Used for Private Clusters"
  default     = []
}

variable "vpc_gateway_endpoints" {
  type        = list(string)
  description = "List of Services to create VPC Gateway Endpoints. Used for Private Clusters"
  default     = []
}