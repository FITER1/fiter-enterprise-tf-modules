data "aws_caller_identity" "current" {}

locals {
  setvalues = var.ingress_class_name == "nginx" ? concat(local.nginx_annotations, var.set_values_argocd_helm) : var.set_values_argocd_helm
  nginx_annotations = [
    {
      name  = "server.ingress.annotations.cert-manager\\.io/cluster-issuer"
      value = var.ingress_cert_issuer
    }
  ]

  local_project = [
    {
      project_name          = var.eks_cluster_name
      project_description   = "Argocd Deployment Project"
      destination_namespace = "*"
      destination_server    = "https://kubernetes.default.svc"
    }
  ]
  client_projects = [
    for cluster in var.argocd_clients : {
      project_name          = "${cluster.name}"
      project_description   = "${cluster.name} Cluster Project"
      destination_namespace = "*"
      destination_server    = "${cluster.server}"
    }
  ]

  projects = concat(local.local_project, local.client_projects)

  eks_helm_map = {
    argocd_ingress_enabled           = var.argocd_ingress_enabled
    argocd_role_arn                  = var.argocd_role_arn
    argocd_domain                    = var.argocd_domain
    ingress_class_name               = var.ingress_class_name
    ingress_tls_enabled              = var.ingress_tls_enabled
    enable_applicationset_controller = var.enable_applicationset_controller
    enable_argocd_notifications      = var.enable_argocd_notifications
    argocd_server_replicas           = var.argocd_server_replicas
    argocd_server_pdb_enabled        = var.argocd_server_pdb_enabled
    argocd_server_min_pdb            = var.argocd_server_min_pdb
    projects                         = local.projects
    alb_ingress_scheme               = var.alb_ingress_scheme
  }
}

resource "helm_release" "argocd" {
  name       = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  version    = var.argocd_version
  chart      = "argo-cd"
  namespace  = var.k8s_namespace
  values = [
    templatefile("${path.module}/files/base-config.yaml", local.eks_helm_map)
  ]

  create_namespace = true
  dynamic "set" {
    for_each = { for set in local.setvalues : set.name => set }
    content {
      name  = set.key
      value = set.value.value
    }
  }
}

resource "helm_release" "argoapps" {
  name       = "argocd-apps"
  repository = "https://argoproj.github.io/argo-helm"
  version    = var.argoapps_version
  chart      = "argocd-apps"
  namespace  = var.k8s_namespace
  values = [
    templatefile("${path.module}/files/argocd-apps.yaml.tmpl", {
      applications = var.argocd_root_applications
      projects     = local.projects
    })
  ]
  create_namespace = true
  depends_on       = [helm_release.argocd]
}

# ------------------------------------------------------------------------------------------------
# Argocd Configurations
# ------------------------------------------------------------------------------------------------
# todo add support for non external secrets users
resource "kubectl_manifest" "default_cluster" {
  yaml_body = templatefile("${path.module}/files/default-cluster.yaml", {
    cluster_name     = var.eks_cluster_name
    cluster_endpoint = "https://kubernetes.default.svc"
    namespace        = var.k8s_namespace
  })
  depends_on = [helm_release.argocd]
}

resource "kubectl_manifest" "argocd_clients" {
  for_each = { for client in var.argocd_clients : client.name => client }
  yaml_body = templatefile("${path.module}/files/clusters-external-secret.yaml", {
    cluster_name       = each.key
    argocd_client_role = each.value.client_role_arn
    namespace          = var.k8s_namespace
    aws_parameter      = "/kubernetes/${each.key}"
    server_endpoint    = each.value.server
  })
  depends_on = [helm_release.argocd]
}

resource "kubectl_manifest" "argocd_repositories" {
  for_each = { for repo in var.argocd_repos : repo.name => repo }
  yaml_body = templatefile("${path.module}/files/repository-external-secret.yaml", {
    repo_config_name = each.key
    aws_parameter    = try(each.value.repo_key_ssm_path, var.argocd_aws_ssm_ssh)
    github_url       = each.value.github_url
    namespace        = var.k8s_namespace
  })
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
