locals {
  slack_hook_url = var.slack_enabled ? var.slack_hook : ""
  slack_channel  = var.slack_enabled ? var.slack_channel : ""
  setvalues      = var.ingress_class_name == "nginx" ? concat(local.nginx_annotations, var.set_values_prometheus_helm) : var.set_values_prometheus_helm
  nginx_annotations = [
    {
      name  = "grafana.ingress.annotations.cert-manager\\.io/cluster-issuer"
      value = var.ingress_cert_issuer
    }
  ]
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.k8s_namespace
  }
}

resource "kubernetes_secret" "grafana_password" {
  metadata {
    name      = "grafana-admin-secret"
    namespace = var.k8s_namespace
  }

  data = {
    admin-user     = "admin"
    admin-password = random_password.password.result
  }
  depends_on = [kubernetes_namespace.monitoring]
}

## Deploy Prometheus and Grafana via Helm charts
resource "helm_release" "prometheus_operator" {
  name             = "kube-prometheus-stack"
  chart            = "kube-prometheus-stack"
  version          = var.prometheus_helm_version
  repository       = "https://prometheus-community.github.io/helm-charts"
  namespace        = var.k8s_namespace
  cleanup_on_fail  = true
  create_namespace = true

  dynamic "set" {
    for_each = { for set in local.setvalues : set.name => set }
    content {
      name  = set.key
      value = set.value.value
    }
  }

  values = [templatefile(
    "${path.module}/values/prometheus.yaml", {
      grafana_enabled : var.grafana_enabled
      SLACK_ENABLED : var.slack_enabled,
      SLACK_HOOK_URL : local.slack_hook_url,
      SLACK_CHANNEL : local.slack_channel,
      STORAGE_CLASS : var.storage_class_type,
      INGRESSENABLED : var.monitoring_ingress_enabled,
      INGRESSHOSTNAME : var.monitoring_hostname,
      INGRESSTLSENABLED : var.ingress_tls_enabled,
      INGRESSCLASSNAME : var.ingress_class_name,
      grafana_resources : var.grafana_resources,
      prom_operator_resources : var.prom_operator_resources,
      kube_state_resources : var.kube_state_resources,
      node_exporter_resources : var.node_exporter_resources,
      prometheus_resource_requests : var.prometheus_resource_requests,
      storage_class_type : var.storage_class_type,
      prometheus_storage_size : var.prometheus_storage_size,
      prometheus_retention_days : var.prometheus_retention_days,
      grafana_storage_size : var.grafana_storage_size,
      enable_grafana_storage : var.enable_grafana_storage,
      alb_ingress_scheme : var.alb_ingress_scheme
      blackbox_targets : var.blackbox_targets
      enable_blackbox_exporter : var.enable_blackbox_exporter
  })]
  depends_on = [kubernetes_secret.grafana_password]
}

variable "grafana_enabled" {
  default     = false
  type        = bool
  description = "Optional. User can enable Grafana"
}

# Logging Helm Chart
resource "helm_release" "loki" {
  name             = "loki-stack"
  chart            = "loki-stack"
  version          = var.loki_helm_version
  repository       = "https://grafana.github.io/helm-charts"
  namespace        = var.k8s_namespace
  create_namespace = true
  cleanup_on_fail  = true

  dynamic "set" {
    for_each = { for set in var.loki_set_values : set.name => set }
    content {
      name  = set.key
      value = set.value.value
    }
  }

  values = [templatefile(
    "${path.module}/values/loki.yaml", {
      eks_log_role : var.eks_log_role,
      service_account_name : var.eks_log_sa_name,
      aws_bucket : var.eks_log_bucket,
      aws_region : var.eks_log_region
      loki_resources : var.loki_resources
      promtail_resources : var.promtail_resources
    }
  )]

  depends_on = [helm_release.prometheus_operator]
}


resource "kubernetes_config_map" "log_dashboard" {
  metadata {
    name      = "log-dashboard"
    namespace = var.k8s_namespace
    labels = {
      "grafana_dashboard" = "1"
    }
    annotations = {
      "grafana_folder" = "App_Dashboard"
    }
  }
  data = {
    "kubernetes_logs.json" = file("${path.module}/dashboards/kube-logs.json")
  }
  depends_on = [helm_release.prometheus_operator]
}

resource "helm_release" "opentelemetry" {
  name             = "opentelemetry-operator"
  chart            = "opentelemetry-operator"
  version          = var.opentelemetry_helm_version
  repository       = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  namespace        = var.k8s_namespace
  create_namespace = true
  cleanup_on_fail  = true

  dynamic "set" {
    for_each = { for set in var.otel_setvalues : set.name => set }
    content {
      name  = set.key
      value = set.value.value
    }
  }

  values = [templatefile(
    "${path.module}/values/otel.yaml", {
      otel_resources : var.otel_resources
    }
  )]

  depends_on = [kubernetes_namespace.monitoring]
}

resource "helm_release" "grafana_tempo" {
  name             = "tempo"
  chart            = "tempo"
  version          = var.tempo_helm_version
  repository       = "https://grafana.github.io/helm-charts"
  namespace        = var.k8s_namespace
  create_namespace = true
  cleanup_on_fail  = true

  dynamic "set" {
    for_each = { for set in var.tempo_setvalues : set.name => set }
    content {
      name  = set.key
      value = set.value.value
    }
  }

  values = [templatefile(
    "${path.module}/values/tempo.yaml", {
      tempo_resources : var.tempo_resources,
      service_account_name : var.eks_log_sa_name,
      eks_log_role : var.eks_log_role,
      enable_metrics_generator : var.enable_tempo_metrics_generator,
      aws_bucket : var.eks_log_bucket,
      aws_region : var.eks_log_region
    }
  )]

  depends_on = [kubernetes_namespace.monitoring]
}

resource "kubernetes_config_map" "tempo_datasource" {
  metadata {
    name      = "tempo-datasource"
    namespace = var.k8s_namespace
    labels = {
      "grafana_datasource" = "1"
    }
  }
  data = {
    "tempo-datasource.yaml" = templatefile("${path.module}/files/tempo-datasource.yaml", {
      tempo_svc : var.tempo_svc,
    })
  }
  depends_on = [
    helm_release.prometheus_operator,
    helm_release.grafana_tempo
  ]
}

resource "kubectl_manifest" "otel_collector" {
  yaml_body = templatefile("${path.module}/files/default-collector.yaml", {
    collector_exporter_endpoint = var.tempo_svc
    k8s_namespace               = var.k8s_namespace
  })
  depends_on = [
    helm_release.opentelemetry,
    helm_release.grafana_tempo
  ]
}

resource "helm_release" "blackbox_exporter" {
  count            = var.enable_blackbox_exporter ? 1 : 0
  name             = "prometheus-blackbox-exporter"
  chart            = "prometheus-blackbox-exporter"
  version          = var.blackbox_helm_version
  repository       = "https://prometheus-community.github.io/helm-charts"
  namespace        = var.k8s_namespace
  cleanup_on_fail  = true
  create_namespace = true

  values = [templatefile(
    "${path.module}/values/blackbox.yaml", {
      blackbox_resources : var.blackbox_resources,
      blackbox_targets : var.blackbox_targets
    }
  )]
}