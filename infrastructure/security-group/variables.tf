variable "name" {
  description = "Name of the security group"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID From VPC Module"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the security group"
  type        = map(string)
  default     = {}
}

variable "security_group_rules" {
  description = "List of security group rules"
  type = list(object({
    description = string
    ip          = string
    name        = string
  }))
}

variable "ports" {
  description = "Port to allow traffic on"
  type        = list(number)
}
