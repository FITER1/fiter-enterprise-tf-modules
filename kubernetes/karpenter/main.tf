locals {
  provisioners = {
    common = {
      node_volume_size        = "100Gi"
      node_volume_type        = "gp3"
      node_encryption_enabled = true
      # instance_category       = ["m", "r", "t"]
    }
  }
}

resource "helm_release" "karpenter" {
  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  namespace           = "karpenter"
  create_namespace    = true
  repository_username = var.ecr_token_username
  repository_password = var.ecr_token_password
  chart               = "karpenter"
  version             = "v0.31.1"
  atomic              = true # wait for deployment to be ready
  cleanup_on_fail     = true
  values = [templatefile("${path.module}/files/values.yaml", {
    KARPENTER_IAM_ROLE_ARN = var.karpenter_iam_role,
    CLUSTER_NAME           = var.cluster_name,
    CLUSTER_ENDPOINT       = var.cluster_endpoint,
    INSTANCE_PROFILE_NAME  = var.instance_profile_name
  })]

  lifecycle {
    ignore_changes = [repository_password]
  }
}

resource "time_sleep" "wait" {
  create_duration = "40s"
  depends_on      = [helm_release.karpenter]
}

resource "kubectl_manifest" "karpenter_provisioner" {
  for_each = local.provisioners
  yaml_body = templatefile("${path.module}/files/provisioners.yaml", {
    provisioner_name        = each.key
    aws_subnet_ids          = join(",", var.vpc_private_subnets)
    aws_security_group_ids  = var.eks_node_security_group_id
    node_volume_size        = lookup(each.value, "node_volume_size", "100Gi")
    node_volume_type        = lookup(each.value, "node_volume_type", "gp3")
    node_encryption_enabled = lookup(each.value, "node_encryption_enabled", true)
  })
  depends_on = [time_sleep.wait]
}
