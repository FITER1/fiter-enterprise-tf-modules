locals {
  eks_log_bucket = "${var.eks_logging_bucketname}-${local.cluster_name}-${local.account_id}"
  account_id     = data.aws_caller_identity.current.id
  prefix         = format("%s-%s", var.customer, var.environment)
  cluster_name   = "${var.customer}-${var.environment}"
  args           = var.assume_role_arn == "" ? ["eks", "get-token", "--cluster-name", local.cluster_name] : ["eks", "get-token", "--cluster-name", local.cluster_name, "--role-arn", "${var.assume_role_arn}"]

  kube_deploy_user = var.helm_deploy ? [{
    rolearn  = "arn:aws:iam::${local.account_id}:role/${local.cluster_name}-ghdeploy-role-kube-deploy"
    username = "helm-ci-deployer"
    groups   = ["ci-user"]
  }] : []

  node_security_group_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    },
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    },
    ingress_control_plane = {
      description                   = "Control plane to node ephemeral ports"
      protocol                      = "-1"
      from_port                     = 1024
      to_port                       = 65535
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  node_group_arns = [
    for key, node in module.eks.eks_managed_node_groups : node.iam_role_arn
  ]

  node_roles_arns = flatten([
    module.karpenter.node_iam_role_arn,
    local.node_group_arns
  ])

  node_roles = [
    for roles in local.node_roles_arns : {
      rolearn  = roles
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:bootstrappers",
        "system:nodes",
      ]
    }
  ]

  auth_roles = [
    for role in var.aws_auth_roles : {
      rolearn  = role
      username = role
      groups   = ["system:masters"]
    }
  ]

  eks_auth_users = [
    for user in var.aws_auth_users :
    {
      userarn  = format("arn:aws:iam::%s:user/%s", local.account_id, user)
      username = user
      groups   = ["system:masters"]
    }
  ]

  eks_auth_roles = concat(local.auth_roles, local.node_roles, local.kube_deploy_user)
}
