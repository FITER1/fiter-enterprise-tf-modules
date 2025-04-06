output "iam_role_arn" {
  value = { for k, role in module.eks_iam_role : k => role.arn }
}

output "cluster_metadata" {
  value = merge([
    for key, value in local.enabled_service_accounts : {
      "${key}_iam_role_arn"    = module.eks_iam_role[key].arn
      "${key}_namespace"       = value["namespace"]
      "${key}_service_account" = value["serviceaccount_name"]
    }
  ]...)
}