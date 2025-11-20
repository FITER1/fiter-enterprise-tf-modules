variable "k8s_namespace" {
  default     = "argocd"
  description = "Namespace to Deploy Argocd"
  type        = string
}

variable "aws_region" {
  description = "AWS Region to Where ECR Registry Resides"
  type        = string
}

variable "argocd_repos" {
  type = map(object({
    type         = string
    ssh_key      = optional(string, "")
    url          = string
    generate_ssh = optional(bool, false)
    username     = optional(string, "")
    password     = optional(string, "")
  }))

  description = "List of Repository containing githuburl, name and type"
  default     = {}

  validation {
    condition = alltrue([
      for key, value in var.argocd_repos : contains(["git", "ssh"], value.type)
    ])
    error_message = "type can be only be `ssh` or `git`"
  }
}

variable "argocd_clients" {
  description = "List of Argocd Clients containing name and Client Role"
  type        = map(any)
  default     = {}
}

variable "argocd_root_applications" {
  description = "List of Root Applications to Deploy"
  type        = list(any)
  default     = []
}

variable "argocd_enabled" {
  description = "Deploy Argocd Helm"
  default     = false
  type        = bool
}

// deprecated. removed in next release
// argocd no longer needs to shared by multiple clusters
// also to enforce least privilege
variable "argocd_role_arn" {
  description = "Argocd Service Account Role Arn"
  type        = string
  default     = ""
}

variable "argocd_domain" {
  description = "Argocd Host Domain"
  type        = string
}

variable "argocd_version" {
  default     = "7.6.12"
  description = "Version of Argocd Helm to Use"
  type        = string
}


variable "argocd_set_values" {
  default     = []
  description = "Arguement for setting Values in Helm Chart that are not passed in the values files"
  type        = list(any)
}

variable "eks_cluster_name" {
  type        = string
  description = "Name of Kubernetes Cluster. Note. change to Cluster"
}

variable "set_values_argocd_helm" {
  type        = list(any)
  description = "List of Set Command to Pass to Prometheus Helm Install"
  default     = []
}

variable "enable_argocd_notifications" {
  type        = bool
  description = "Enable Argocd Notification"
  default     = false
}

variable "slack_token" {
  type        = string
  description = "Slack Token to Send Notifications"
  default     = ""
  sensitive   = true
}

variable "argocd_server_replicas" {
  type        = number
  description = "number of replicas for argpcd server"
  default     = 1
}

variable "argocd_server_pdb_enabled" {
  type        = bool
  description = "enable pod pdb for rapid scaling environments, ensure replicas is over one to enable pdb"
  default     = false
}

variable "argocd_server_min_pdb" {
  type        = number
  description = "minimum number of allowed available pods when pdb is enabled"
  default     = 1
}

variable "argoapps_version" {
  type        = string
  description = "Version of argocd app helm chart"
  default     = "2.0.2"
}


variable "cluster_annotations" {
  type        = map(any)
  description = "Annotations to add to argocd cluster secret"
  default     = {}
}

variable "cluster_labels" {
  type        = map(any)
  description = "Labels to add to argocd cluster secret"
  default     = {}
}

variable "environment" {
  type        = string
  description = "Environment Prod, Development or staging"
  default     = "dev"
}

variable "projects" {
  type = list(object({
    project_name          = string
    project_description   = string
    destination_namespace = optional(string, "*")
    destination_server    = optional(string, "https://kubernetes.default.svc")
  }))
  description = "List of Projects to Deploy"
  default     = []
}

variable "enable_ui_exec" {
  type        = bool
  description = "Enable Exec through argocd UI"
  default     = false
}

variable "argocd_users" {
  type = map(object({
    role = string
  }))
  description = "List of Users to add to Argocd"
  default     = {}
}

variable "ingress_configurations" {
  type = object({
    enabled     = optional(bool, false)
    class       = optional(string, "nginx")
    tls         = optional(bool, false)
    annotations = optional(map(string), {})
    controller  = optional(string, "generic")
  })
  description = "Configurations to add for argocd ingress"
  default     = {}
  validation {
    condition = contains(["generic", "aws"], var.ingress_configurations.controller)
    error_message = "controller must be either 'generic' or 'aws'."
  }

  validation {
    condition = contains(["nginx", "alb"], var.ingress_configurations.class)
    error_message = "class must be either 'nginx' or 'alb'."
  }
}

variable "crossplane_enabled" {
  type        = bool
  description = "Enable Crossplane related Configuration"
  default     = false
}