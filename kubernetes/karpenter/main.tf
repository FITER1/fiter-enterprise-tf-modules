resource "helm_release" "karpenter" {
  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  namespace           = "karpenter"
  create_namespace    = true
  repository_username = var.ecr_token_username
  repository_password = var.ecr_token_password
  chart               = "karpenter"
  version             = "1.0.6"
  atomic              = true # wait for deployment to be ready
  cleanup_on_fail     = true
  values = [templatefile("${path.module}/files/values.yaml", {
    KARPENTER_IAM_ROLE_ARN = var.karpenter_iam_role,
    KARPENTER_QUEUE_NAME   = var.karpenter_queue_name
    CLUSTER_NAME           = var.cluster_name
  })]
}

resource "helm_release" "karpenter-crd" {
  name                = "karpenter-crd"
  repository          = "oci://public.ecr.aws/karpenter"
  namespace           = "karpenter"
  create_namespace    = true
  repository_username = var.ecr_token_username
  repository_password = var.ecr_token_password
  chart               = "karpenter-crd"
  version             = "1.0.6"
  atomic              = true # wait for deployment to be ready
  cleanup_on_fail     = true
}

resource "time_sleep" "wait" {
  create_duration = "40s"
  depends_on      = [helm_release.karpenter]
}

resource "kubectl_manifest" "karpenter_nodeclass" {
  yaml_body = templatefile("${path.module}/files/nodeclass.yaml", {
    CLUSTER_NAME            = var.cluster_name
    NODE_SECURITY_GROUP_ID  = var.eks_node_security_group_id
    INSTANCE_PROFILE_NAME   = var.instance_profile_name
    NODE_VOLUME_SIZE        = lookup(var.node_config, "node_volume_size", "100Gi")
    NODE_VOLUME_TYPE        = lookup(var.node_config, "node_volume_type", "gp3")
    NODE_ENCRYPTION_ENABLED = lookup(var.node_config, "node_encryption_enabled", true)
    NODE_IOPS               = lookup(var.node_config, "node_iops", 3000)
  })
  depends_on = [time_sleep.wait]
}

resource "kubectl_manifest" "karpenter_nodepool" {
  count      = var.use_custom_nodepool ? 0 : 1
  yaml_body  = file("${path.module}/files/nodepool.yaml")
  depends_on = [kubectl_manifest.karpenter_nodeclass]
}

resource "kubectl_manifest" "karpenter_custom_nodepool" {
  count      = var.use_custom_nodepool ? 1 : 0
  yaml_body  = file("${path.root}/${var.custom_nodepool_path}")
  depends_on = [kubectl_manifest.karpenter_nodeclass]
}
