/*
 * # AWS GitOps Terraform Module
 *
 * This module sets up ArgoCD on an EKS cluster using Helm.
 *
 * ## Features:
 * - Creating Helm releases for ArgoCD and its applications.
 * - Configuring Kubernetes secrets for clusters and repositories.
 * - Generating SSH keys for repositories if needed.
 * - Storing public SSH keys in AWS SSM Parameter Store.
 * - Optionally configuring Slack notifications for ArgoCD.
 *
 *
 * ## Resources:
 * - Helm Releases.
*/

data "aws_caller_identity" "current" {}

locals {
  setvalues = var.set_values_argocd_helm

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
  }
}

resource "helm_release" "argocd" {
  name             = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  version          = var.argocd_version
  chart            = "argo-cd"
  namespace        = var.k8s_namespace
  create_namespace = true
  wait             = false
  wait_for_jobs    = false

  values = [
    templatefile("${path.module}/files/base-config.yaml", local.eks_helm_map)
  ]

  set = var.set_values_argocd_helm
}

resource "helm_release" "argoapps" {
  name             = "argocd-apps"
  repository       = "https://argoproj.github.io/argo-helm"
  version          = var.argoapps_version
  chart            = "argocd-apps"
  namespace        = var.k8s_namespace
  create_namespace = true
  wait             = false
  wait_for_jobs    = false

  values = [
    templatefile("${path.module}/files/argocd-apps.yaml.tmpl", {
      applications = var.argocd_root_applications
      projects     = local.projects
    })
  ]
  depends_on = [helm_release.argocd]
}

# ------------------------------------------------------------------------------------------------
# Argocd Configurations
# ------------------------------------------------------------------------------------------------

resource "kubernetes_secret_v1" "default_cluster" {
  metadata {
    name        = "${var.eks_cluster_name}-cluster-secret"
    namespace   = var.k8s_namespace
    annotations = var.cluster_annotations

    labels = merge(var.cluster_labels, {
      "argocd.argoproj.io/secret-type" = "cluster"
      clustername                      = var.eks_cluster_name
      environment                      = var.environment
      region                           = var.aws_region
    })
  }

  data = {
    name   = var.eks_cluster_name
    server = "https://kubernetes.default.svc"
    config = <<EOF
    {
      "tlsClientConfig" : {
        "insecure" : false
      }
    }
    EOF
  }

  depends_on = [helm_release.argocd]
}

resource "kubernetes_secret_v1" "argocd_repositories" {
  for_each = var.argocd_repos

  metadata {
    name      = each.key
    namespace = var.k8s_namespace
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = each.value.type == "ssh" ? {
    type          = "git"
    sshPrivateKey = each.value.generate_ssh ? tls_private_key.argocdsshkey[each.key].private_key_openssh : each.value.ssh_key
    url           = each.value.url
    } : {
    type     = "git"
    username = each.value.username
    url      = each.value.url
    password = each.value.password
  }

  depends_on = [helm_release.argocd]
}

resource "kubernetes_secret" "argo_notification_secret" {
  count = var.enable_argocd_notifications ? 1 : 0

  metadata {
    name      = "argocd-notifications-secret"
    namespace = var.k8s_namespace
  }

  data = {
    slack-token = var.slack_token
  }
}

# ED25519 key
resource "tls_private_key" "argocdsshkey" {
  for_each = { for key, value in var.argocd_repos : key => value if value.generate_ssh }

  algorithm = "ED25519"
}

resource "aws_ssm_parameter" "argocd_public_key" {
  for_each = { for key, value in var.argocd_repos : key => value if value.generate_ssh }

  name  = "/argocd/git/argocd-user/${var.eks_cluster_name}/${each.key}/github_public_sshkey"
  type  = "SecureString"
  value = tls_private_key.argocdsshkey[each.key].public_key_openssh
}
