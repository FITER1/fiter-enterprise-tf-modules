data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  eks_helm_map = {
    aws_region              = data.aws_region.current.name
    vpc_id                  = var.vpc_id
    cluster_name            = var.eks_cluster_name
    account_id              = data.aws_caller_identity.current.account_id
    external_secret_sa_role = var.service_account_arns["external-secret"]
  }

  helm_releases = {
    cluster-autoscaler = {
      enabled    = var.cluster_autoscaler_enabled
      repository = "https://kubernetes.github.io/autoscaler"
      chart      = "cluster-autoscaler"
      version    = var.cluster_autoscaler_version
      namespace  = "kube-system"
      values     = [templatefile("${path.module}/values/cluster-autoscaler.yaml", local.eks_helm_map)]
    },
    metrics-server = {
      enabled    = var.metric_server_enabled
      repository = "https://charts.bitnami.com/bitnami"
      chart      = "metrics-server"
      version    = var.metrics_server_version
      namespace  = "kube-system"
      values = [templatefile("${path.module}/values/metrics-server.yaml", {
        metrics_server_resources = var.metrics_server_resources
      })]
    },
    cert-manager = {
      enabled          = var.cert_manager_enabled
      repository       = "https://charts.jetstack.io"
      chart            = "cert-manager"
      version          = var.cert_manager_version
      namespace        = "cert-manager"
      create_namespace = true
      values = [templatefile("${path.module}/values/cert-manager.yaml", {
        cert_manager_resources : var.cert_manager_resources
      })]
    },
    nginx-ingress = {
      enabled          = var.nginx_ingress_enabled
      repository       = "https://kubernetes.github.io/ingress-nginx"
      chart            = "ingress-nginx"
      version          = var.nginx_ingress_version
      namespace        = "kube-system"
      create_namespace = true
      values           = [file("${path.module}/values/nginx-ingress.yaml")]
    },
    alb-ingress = {
      enabled          = var.alb_ingress_enabled
      repository       = "https://aws.github.io/eks-charts"
      chart            = "aws-load-balancer-controller"
      version          = var.alb_ingress_version
      namespace        = "kube-system"
      create_namespace = true
      values = [templatefile("${path.module}/values/alb.yaml", merge(local.eks_helm_map, {
        alb_resources = var.alb_resources,
      }))]
    },
    external-secret = {
      enabled          = var.external_secret_enabled
      repository       = "https://charts.external-secrets.io"
      chart            = "external-secrets"
      version          = var.external_secret_version
      namespace        = var.external_secrets_namespace
      create_namespace = true
      values = [templatefile("${path.module}/values/external-secret.yaml", {
        external_secret_resources : var.external_secret_resources
      })]
    }
  }
  enabled_helm_releases = { for key, value in local.helm_releases : key => value if value.enabled == true }
}

resource "helm_release" "this" {
  for_each = local.enabled_helm_releases

  name       = each.key
  repository = each.value.repository
  version    = each.value.version
  chart      = each.value.chart
  namespace  = each.value.namespace
  values     = each.value.values

  create_namespace = true
}

# ------------------------------------------------------------------------------------------------
# CertBot Issuers
# ------------------------------------------------------------------------------------------------
resource "kubectl_manifest" "certbot_prod" {
  count = var.cert_manager_enabled && var.enable_cluster_issuer ? 1 : 0
  yaml_body = file("${path.module}/manifests/clusterissuer.yaml")
  depends_on = [helm_release.this]
}

# ------------------------------------------------------------------------------------------------
# Storage Class changes (make gp2 not default, add gp3 as default, and gp3-kms-enc for encrypted
# ------------------------------------------------------------------------------------------------
# gp3 storage class for cheaper storage
resource "kubernetes_annotations" "change_default_storage_class" {
  count       = var.enable_gp3_storage ? 1 : 0
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  metadata {
    name = "gp2"
  }
  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "false"
  }
  force = true
}

resource "kubernetes_manifest" "gp3" {
  count = var.enable_gp3_storage ? 1 : 0
  manifest = {
    "apiVersion" = "storage.k8s.io/v1"
    "kind"       = "StorageClass"
    "metadata" = {
      "name" = "gp3"
      "annotations" = {
        "storageclass.kubernetes.io/is-default-class" = "true"
      }
    }
    "provisioner" : "ebs.csi.aws.com"
    "parameters" = {
      "fsType" = "ext4"
      "type"   = "gp3"
    }
    "reclaimPolicy"        = "Delete"
    "allowVolumeExpansion" = true
  }
  depends_on = [
    kubernetes_annotations.change_default_storage_class
  ]
}

# ------------------------------------------------------------------------------------------------
# External Secret Store
# ------------------------------------------------------------------------------------------------
resource "kubernetes_service_account" "external_secret_irsa" {
  count = var.external_secret_enabled && var.external_aws_secret_manager_store_enabled ? 1 : 0
  metadata {
    name      = "external-secrets-irsa"
    namespace = var.external_secrets_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = local.eks_helm_map["external_secret_sa_role"]
    }
  }
  secret {
    name = kubernetes_secret.external_secret_irsa[0].metadata.0.name
  }
}

resource "kubernetes_secret" "external_secret_irsa" {
  count = var.external_secret_enabled && var.external_aws_secret_manager_store_enabled ? 1 : 0
  metadata {
    name      = "external-secrets-irsa"
    namespace = var.external_secrets_namespace
  }
}

resource "kubectl_manifest" "secretmanagerstore" {
  count = var.external_secret_enabled && var.external_aws_secret_manager_store_enabled ? 1 : 0
  yaml_body = templatefile("${path.module}/manifests/secret-store.yaml",{
    aws_region = data.aws_region.current.name
    namespace = var.external_secrets_namespace
  })
  depends_on = [helm_release.this]
}


resource "kubectl_manifest" "parameterstore" {
  count = var.external_secret_enabled && var.external_aws_secret_parameter_store_enabled ? 1 : 0
  yaml_body = templatefile("${path.module}/manifests/parameter-store.yaml",{
    aws_region = data.aws_region.current.name
    namespace = var.external_secrets_namespace
  })
  depends_on = [
    helm_release.this
  ]
}

data "kubernetes_resource" "ingress" {
  count = var.nginx_ingress_enabled ? 1 : 0
  api_version = "v1"
  kind        = "Service"

  metadata {
    name      = "nginx-ingress-ingress-nginx-controller"
    namespace = "kube-system"
  }
  depends_on = [ helm_release.this ]
}

output "nginx_ingress_hostname" {
  value = try(data.kubernetes_resource.ingress[0].object.status.loadBalancer.ingress[0].hostname, null)
}
