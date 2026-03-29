variable "deployment_role_name" {
  type        = string
  description = "The name of the Terraform IAM deployment role"
}

variable "ci_pipelines_roles" {
  type        = map(any)
  description = "CI Policies to attach"
  default     = {}
}

variable "create_admin_role" {
  default     = true
  type        = bool
  description = "Whether to create an admin role for the deployment role"
}
