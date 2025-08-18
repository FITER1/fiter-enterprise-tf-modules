locals {
  eks_roles = {
    aws_alb = {
      role_name           = "${var.eks_cluster_name}-alb-controller"
      namespace           = var.alb_k8s_namespace
      serviceaccount_name = var.alb_sa_name
      role_policy_arn     = try([aws_iam_policy.lb_controller[0].arn], [])
      enabled             = var.enable_alb_controller
    },
    argocd_controller = {
      role_name           = "${var.eks_cluster_name}-argoCD"
      namespace           = var.argocd_k8s_namespace
      serviceaccount_name = var.argocd_sa_name
      role_policy_arn     = try([aws_iam_policy.argo_cd[0].arn], [])
      enabled             = var.enable_argocd
    },
    cluster_autoscaler = {
      role_name           = "${var.eks_cluster_name}-autoscaler"
      namespace           = var.ca_k8s_namespace
      serviceaccount_name = var.ca_sa_name
      role_policy_arn     = try([aws_iam_policy.cluster_autoscaler[0].arn], [])
      enabled             = var.enable_cluster_autoscaler
    },
    external_dns = {
      role_name           = "${var.eks_cluster_name}-extDNS"
      namespace           = var.extDNS_k8s_namespace
      serviceaccount_name = var.extDNS_sa_name
      role_policy_arn     = try([aws_iam_policy.external_dns[0].arn], [])
      enabled             = var.enable_external_dns
    },
    eks_log = {
      role_name           = "${var.eks_cluster_name}-eks-logs"
      namespace           = var.monitoring_namespace
      serviceaccount_name = var.monitoring_sa_name
      role_policy_arn     = try([aws_iam_policy.eks_logger[0].arn])
      enabled             = var.enable_eks_log_bucket
    },
    external_secret = {
      role_name           = "${var.eks_cluster_name}-eks-external-secrets"
      namespace           = "kube-system"
      serviceaccount_name = var.external_secret_sa_name
      role_policy_arn     = try([aws_iam_policy.external_secret[0].arn], [])
      enabled             = var.eks_external_secret_enabled
    }
  }

  additional_policies = {
    for key, value in var.additional_policies :
    key => {
      role_name           = "${var.eks_cluster_name}-${key}"
      namespace           = value.namespace
      serviceaccount_name = value.serviceaccount_name
      role_policy_arn     = [aws_iam_policy.eks_apps_service_account_policy[key].arn]
      enabled             = true
    }
  }
  enabled_service_accounts = { for key, value in merge(local.eks_roles, local.additional_policies) : key => value if value.enabled == true }
}
