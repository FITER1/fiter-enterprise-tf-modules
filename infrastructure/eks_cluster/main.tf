# ------------------------------------------------------------------------------
# eks module
# ------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

locals {
  account_id = data.aws_caller_identity.current.id
  prefix     = format("%s-%s", var.customer, var.environment)
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
  cluster_name = "${var.customer}-${var.environment}"
}


module "eks" {
  source                    = "terraform-aws-modules/eks/aws"
  version                   = "~> 19.0"
  cluster_name              = local.cluster_name
  cluster_version           = var.cluster_version
  subnet_ids                = var.subnets
  vpc_id                    = var.vpc_id
  enable_irsa               = true

  cluster_addons = {
    coredns = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    kube-proxy = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    vpc-cni = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    aws-ebs-csi-driver = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      service_account_role_arn    = module.aws_ebs_csi_iam_service_account.iam_role_arn
    }
  }

  cluster_security_group_description = "The security group of the NK EKS cluster"
  cluster_security_group_name        = "${local.prefix}-sg"
  prefix_separator                   = "-"
  iam_role_name                      = "${local.prefix}-role"

  cluster_endpoint_public_access     = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  eks_managed_node_group_defaults = {
    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs         = {
          delete_on_termination = true
          encrypted             = true
          volume_size           = 75
          iops                  = 3000
          throughput            = 150
          volume_type           = "gp3"
          kms_key_id            = module.ebs_kms_key.key_arn
        }
      }
    }
  }

  create_iam_role          = true

  eks_managed_node_groups = {
    for key, value in var.node_groups_attributes :
    key => {
      min_size     = value["min_size"]
      max_size     = value["max_size"]
      desired_size = value["desired_size"]
      disk_size    = value["disk_size"]
      taints       = lookup(value, "taints", [])
      subnet_ids   = lookup(value, "subnet_ids", var.subnets)

      instance_types = value["instance_types"]
      capacity_type  = value["capacity_type"]
    }
  }

  iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  }
  # Allow Extending without making module changes
  node_security_group_additional_rules = merge(local.node_security_group_rules, var.node_security_group_additional_rules)

  tags = var.common_tags

  manage_aws_auth_configmap = true
  # create_aws_auth_configmap = true

  aws_auth_roles = var.aws_auth_roles

  aws_auth_users = var.aws_auth_users
}

module "ebs_kms_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 1.5"

  description = "Customer managed key to encrypt EKS managed node group volumes"

  # Policy
  key_administrators = [
    data.aws_caller_identity.current.arn
  ]

  key_service_roles_for_autoscaling = [
    # required for the ASG to manage encrypted volumes for nodes
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
    # required for the cluster / persistentvolume-controller to create encrypted PVCs
    module.eks.cluster_iam_role_arn,
  ]

  # Aliases
  aliases = ["eks/${local.prefix}/ebs"]

  tags = var.common_tags
}

##############################
# EBS CSI Role
##############################

resource "aws_kms_key" "gp3_kms" {
  description             = "KMS key for ${module.eks.cluster_name} EBS volumes"
  deletion_window_in_days = 10
}

# policy for gp3 and gp3 encrypted storage using EBS CSI Driver
data aws_iam_policy_document aws_ebs_csi_driver_encryption {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    resources = [aws_kms_key.gp3_kms.arn]
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
  statement {
    effect  = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = [aws_kms_key.gp3_kms.arn]
  }
}

resource "aws_iam_policy" "aws_ebs_csi" {
  name_prefix = "${local.prefix}-aws-ebs-csi"
  description = "Ebs policy for cluster ${local.prefix}"
  policy      = data.aws_iam_policy_document.aws_ebs_csi_driver_encryption.json
}

module "aws_ebs_csi_iam_service_account" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.28.0"
  create_role                   = true
  role_name                     = "${local.prefix}-aws-ebs-csi"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.aws_ebs_csi.arn, "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}