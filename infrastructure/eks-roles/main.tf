/*
 * # AWS EKS IAM Role and Policy Terraform Module
 *
 * This module manages AWS IAM roles and policies required for Kubernetes applications running on an [EKS Cluster](https://aws.amazon.com/eks/).
 *
 * It creates IAM roles for various services and assigns the necessary permissions based on predefined policies.
 * Additionally, it allows the use of OIDC for secure access to AWS resources from the Kubernetes service accounts.
 * The module automatically associates the service accounts with the corresponding IAM roles, making it easier to manage permissions at the Kubernetes level.
 * 
 * The IAM policies are generated dynamically based on input policy files and associated with the roles. For additional flexibility, the module supports adding custom policies through the `additional_policies` variable.
 *
 */

resource "aws_iam_policy" "eks_apps_service_account_policy" {
  for_each    = var.additional_policies
  name        = "${var.eks_cluster_name}-${each.key}"
  description = "Permissions required by the Kubernetes Pods to access AWS Resources"
  policy      = each.value.policy
}

module "eks_iam_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 5.59.0"
  for_each                      = local.enabled_service_accounts
  create_role                   = true
  role_name                     = each.value.role_name
  provider_url                  = replace(var.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = each.value.role_policy_arn
  number_of_role_policy_arns    = 1
  oidc_fully_qualified_subjects = strcontains(each.value.serviceaccount_name, "*") ? [] : ["system:serviceaccount:${each.value.namespace}:${each.value.serviceaccount_name}"]
  oidc_subjects_with_wildcards  = strcontains(each.value.serviceaccount_name, "*") ? ["system:serviceaccount:${each.value.namespace}:${each.value.serviceaccount_name}"] : []
}
