output "cluster_oidc_issuer_url" {
  value       = module.eks.cluster_oidc_issuer_url
  description = "value of the cluster OIDC issuer URL"
}

output "cluster_name" {
  value       = module.eks.cluster_name
  description = "value of the cluster name"
}

output "cluster_arn" {
  value       = module.eks.cluster_arn
  description = "value of the cluster ARN"
}

output "node_security_group_ids" {
  value       = module.eks.node_security_group_id
  description = "value of the node security group ID"
}

output "node_security_group_id" {
  value       = module.eks.node_security_group_id
  description = "value of the node security group ID"
}

output "karpenter_role_arn" {
  value       = module.karpenter.iam_role_arn
  description = "value of the Karpenter IAM role ARN"
}

output "karpenter_instance_profile" {
  value       = module.karpenter.instance_profile_name
  description = "value of the Karpenter instance profile name"
}

output "karpenter_queue_name" {
  value       = module.karpenter.queue_name
  description = "value of the Karpenter queue name"
}

output "oidc_provider_arn" {
  value       = module.eks.oidc_provider_arn
  description = "value of the OIDC provider ARN"
}

output "managed_group" {
  value       = module.eks.eks_managed_node_groups
  description = "value of the managed node group"
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}