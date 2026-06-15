terraform {
  required_version = ">= 1.5"
}

variable "eks_cluster_name" {
  type    = string
  default = "kitchensink-cluster"
}

variable "argocd_domain" {
  type    = string
  default = "argocd.kitchensink.example.io"
}

variable "argocd_server_replicas" {
  type    = number
  default = 2
}

variable "argocd_server_pdb_enabled" {
  type    = bool
  default = true
}

variable "argocd_server_min_pdb" {
  type    = number
  default = 1
}

variable "enable_argocd_notifications" {
  type    = bool
  default = true
}

variable "enable_ui_exec" {
  type    = bool
  default = true
}

variable "crossplane_enabled" {
  type    = bool
  default = true
}

variable "ingress_configurations" {
  type = object({
    enabled     = optional(bool, false)
    class       = optional(string, "nginx")
    tls         = optional(bool, false)
    annotations = optional(map(string), {})
    controller  = optional(string, "generic")
  })
  default = {
    enabled    = true
    class      = "alb"
    tls        = true
    controller = "aws"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
    }
  }
}

variable "argocd_users" {
  type = map(object({
    role = string
  }))
  default = {
    alice = { role = "developer" }
    bob   = { role = "admin" }
  }
}

variable "projects" {
  type = list(object({
    project_name          = string
    project_description   = string
    destination_namespace = optional(string, "*")
    destination_server    = optional(string, "https://kubernetes.default.svc")
  }))
  default = [
    {
      project_name        = "team-payments"
      project_description = "Payments team deployment project"
    }
  ]
}

variable "argocd_root_applications" {
  type = list(any)
  default = [
    {
      app_name       = "bootstrap-addons"
      repository_url = "https://github.com/example-org/argocd-apps.git"
      repo_path      = "bootstrap/addons"
      branch         = "main"
    },
    {
      app_name       = "platform-apps"
      repository_url = "https://github.com/example-org/argocd-apps.git"
      repo_path      = "platform"
      branch         = "main"
    }
  ]
}

locals {
  dev_users = [
    for key, user in var.argocd_users : key if user.role == "developer"
  ]

  admin_users = [
    for key, user in var.argocd_users : key if user.role == "admin"
  ]

  main_project = [
    {
      project_name          = var.eks_cluster_name
      project_description   = "${var.eks_cluster_name} Deployment Project"
      destination_namespace = "*"
      destination_server    = "https://kubernetes.default.svc"
    }
  ]

  projects = concat(local.main_project, var.projects)

  eks_helm_map = {
    argocd_ingress_enabled      = var.ingress_configurations.enabled
    ingress_class_name          = var.ingress_configurations.class
    ingress_tls_enabled         = var.ingress_configurations.tls
    ingress_annotations         = var.ingress_configurations.annotations
    ingress_controller          = var.ingress_configurations.controller
    argocd_domain               = var.argocd_domain
    enable_argocd_notifications = var.enable_argocd_notifications
    argocd_server_replicas      = var.argocd_server_replicas
    argocd_server_pdb_enabled   = var.argocd_server_pdb_enabled
    argocd_server_min_pdb       = var.argocd_server_min_pdb
    projects                    = local.projects
    developer_projects          = var.projects
    enable_ui_exec              = var.enable_ui_exec
    devusers                    = local.dev_users
    admin_users                 = local.admin_users
    crossplane_enabled          = var.crossplane_enabled
  }
}

output "argocd_values" {
  description = "Rendered base-config.yaml (argo-cd chart values) for the kitchen-sink input set"
  value       = templatefile("${path.module}/../../files/base-config.yaml", local.eks_helm_map)
}

output "argocd_apps_values" {
  description = "Rendered argocd-apps.yaml.tmpl (argocd-apps chart values) for the kitchen-sink input set"
  value = templatefile("${path.module}/../../files/argocd-apps.yaml.tmpl", {
    applications = var.argocd_root_applications
    projects     = local.projects
  })
}
