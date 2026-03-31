/**
 * # AWS EKS Terraform Module
 *
 * This module provisions an [Amazon Elastic Kubernetes Service (EKS)](https://aws.amazon.com/eks/) cluster on AWS.
 *
 * The following resources are created as part of the module:
 * - EKS Cluster: Managed Kubernetes control plane.
 * - Node Groups: Managed or self-managed worker nodes.
 * - IAM Roles and Policies: Configured for cluster, node group, and Kubernetes integration.
 * - VPC Endpoints: Optional private access for clusters with public endpoint disabled.
 * - Cluster Add-ons: Core DNS, VPC CNI, kube-proxy, and AWS EBS CSI driver.
 * - Security Groups: Configured for cluster and node group communication.
 * - S3 Logging Bucket: Optional centralized storage for EKS logging.
 * - KMS Encryption: Enabled for cluster secrets and node group storage.
 * 
 * This module also supports creating fully private clusters, managing AWS Auth for RBAC, and deploying additional integrations such as Karpenter and Helm deployers.
 */

# ------------------------------------------------------------------------------
# eks module
# ------------------------------------------------------------------------------
# support for assume role and other

data "aws_caller_identity" "current" {}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = local.args
  }
}

module "eks" {
  source             = "terraform-aws-modules/eks/aws"
  version            = "~> 21.0"
  name               = local.cluster_name
  kubernetes_version = var.cluster_version
  subnet_ids         = var.subnets
  vpc_id             = var.vpc_id
  enable_irsa        = true

  addons = {
    coredns = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      configuration_values = var.enable_private_zone ? jsonencode({
        corefile = <<-EOT
          .:53 {
              errors
              health {
                  lameduck 5s
                }
              ready
              kubernetes cluster.local in-addr.arpa ip6.arpa {
                pods insecure
                fallthrough in-addr.arpa ip6.arpa
              }
              prometheus :9153
              forward . /etc/resolv.conf
              cache 30
              loop
              reload
              loadbalance
            ${var.private_zone_host_name}:53 {
              errors
              cache 30
              forward . 169.254.169.253
            }  
          }
          EOT
      }) : null
    }
    kube-proxy = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      most_recent                 = true
    }
    vpc-cni = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      most_recent                 = true
      before_compute              = true
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
        }
      })
    }
    aws-ebs-csi-driver = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      most_recent                 = true
      service_account_role_arn    = module.aws_ebs_csi_iam_service_account.arn
    }
    eks-pod-identity-agent = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      most_recent                 = true
      before_compute              = true
    }
  }

  kms_key_administrators     = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
  security_group_description = "The security group of the NK EKS cluster"
  security_group_name        = "${local.prefix}-sg"
  prefix_separator           = "-"
  iam_role_name              = "${local.prefix}-role"

  endpoint_public_access       = var.cluster_endpoint_public_access
  endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  create_iam_role                          = true
  enable_cluster_creator_admin_permissions = true
  access_entries                           = var.eks_access_entries
  authentication_mode                      = var.authentication_mode
  eks_managed_node_groups = {
    for key, value in var.node_groups_attributes :
    key => {
      ami_type     = value["ami_type"]
      min_size     = value["min_size"]
      max_size     = value["max_size"]
      desired_size = value["desired_size"]
      disk_size    = value["disk_size"]
      taints       = lookup(value, "taints", {})
      subnet_ids   = lookup(value, "subnet_ids", var.subnets)

      disable_api_termination        = var.disable_api_termination
      instance_types                 = value["instance_types"]
      capacity_type                  = value["capacity_type"]
      pre_bootstrap_user_data        = lookup(value, "pre_bootstrap_user_data", "")
      use_latest_ami_release_version = lookup(value, "use_latest_ami_release_version", false)
      metadata_options = lookup(value, "metadata_options", {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
      })
      block_device_mappings = lookup(value, "block_device_mappings", {
        root_volume = {
          device_name = "/dev/xvda"
          ebs = {
            delete_on_termination      = true
            encrypted                  = true
            iops                       = 3000
            kms_key_id                 = module.ebs_kms_key.key_arn
            volume_initialization_rate = 100
            volume_size                = 75
            volume_type                = "gp3"
          }
        }
      })
      tags = lookup(value, "tags", {})
    }
  }

  iam_role_additional_policies = merge({
    AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  }, var.additional_cluster_policies)

  node_security_group_additional_rules = merge(local.node_security_group_rules, var.node_security_group_additional_rules)
  security_group_additional_rules = {
    ingress_bastion = {
      description = "Allow access from Bastion Host"
      type        = "ingress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = var.cluster_endpoint_public_access_cidrs
    }
  }

  tags = merge(var.common_tags, {
    "karpenter.sh/discovery" = local.cluster_name
  })
}

module "ebs_kms_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 4.0"

  description = "Customer managed key to encrypt EKS managed node group volumes"

  # Policy
  key_administrators = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.cluster_name}-ghdeploy-role-terraform"
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
  rotation_period_in_days = var.kms_key_rotation_days
  enable_key_rotation     = true
}

# policy for gp3 and gp3 encrypted storage using EBS CSI Driver
data "aws_iam_policy_document" "aws_ebs_csi_driver_encryption" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
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
    effect = "Allow"
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
  source                = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version               = "~> 6.0"
  create                = true
  attach_ebs_csi_policy = true
  name                  = "${local.prefix}-aws-ebs-csi"
  oidc_providers = {
    this = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 21.0"

  cluster_name                    = module.eks.cluster_name
  create_pod_identity_association = true
  create_instance_profile         = false
  create_access_entry             = true
  namespace                       = var.karpenter_namespace
  service_account                 = var.karpenter_service_account
  node_iam_role_additional_policies = merge({
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }, var.additional_cluster_policies)
  tags = var.common_tags
}
