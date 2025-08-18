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
  cluster_ca_certificate = module.eks.cluster_certificate_authority_data != null ? base64decode(module.eks.cluster_certificate_authority_data) : ""

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = local.args
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 20.0"
  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version
  subnet_ids      = var.subnets
  vpc_id          = var.vpc_id
  enable_irsa     = true

  cluster_addons = {
    coredns = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
      configuration_values = var.enable_private_zone ? jsonencode({
        corefile = <<-EOT
            .:53 {
              errors
              health
              kubernetes cluster.local in-addr.arpa ip6.arpa {
                pods insecure
                upstream
                fallthrough in-addr.arpa ip6.arpa
              }
              prometheus :9153
              forward . /etc/resolv.conf
              cache 30
              loop
              reload
              loadbalance
            }
            ${var.private_zone_host_name}:53 {
              errors
              cache 30
              forward . /etc/resolv.conf
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
      service_account_role_arn    = module.aws_ebs_csi_iam_service_account.iam_role_arn
    }
  }

  kms_key_administrators             = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
  cluster_security_group_description = "The security group of the NK EKS cluster"
  cluster_security_group_name        = "${local.prefix}-sg"
  prefix_separator                   = "-"
  iam_role_name                      = "${local.prefix}-role"

  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  eks_managed_node_group_defaults = {
    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
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

  create_iam_role                          = true
  enable_cluster_creator_admin_permissions = true
  access_entries                           = var.eks_access_entries
  authentication_mode                      = var.authentication_mode
  eks_managed_node_groups = {
    for key, value in var.node_groups_attributes :
    key => {
      min_size     = value["min_size"]
      max_size     = value["max_size"]
      desired_size = value["desired_size"]
      disk_size    = value["disk_size"]
      taints       = lookup(value, "taints", [])
      subnet_ids   = lookup(value, "subnet_ids", var.subnets)

      instance_types                 = value["instance_types"]
      capacity_type                  = value["capacity_type"]
      pre_bootstrap_user_data        = lookup(value, "pre_bootstrap_user_data", "")
      use_latest_ami_release_version = lookup(value, "use_latest_ami_release_version", false)
      tags                           = lookup(value, "tags", {})
    }
  }

  iam_role_additional_policies = merge({
    AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  }, var.additional_cluster_policies)

  node_security_group_additional_rules = merge(local.node_security_group_rules, var.node_security_group_additional_rules)
  cluster_security_group_additional_rules = {
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
  version = "~> 3.1"

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
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 5.59.0"
  create_role                   = true
  role_name                     = "${local.prefix}-aws-ebs-csi"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.aws_ebs_csi.arn, "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

module "eks_log_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~>4.2.0"

  bucket                   = local.eks_log_bucket
  acl                      = "private"
  force_destroy            = true
  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
  lifecycle_rule = [for key, property in var.log_bucket_lifecycle_rules : {
    id      = key
    enabled = true
    filter = {
      prefix = property.path
    }
    expiration = {
      days                         = property.expiration_days
      expired_object_delete_marker = lookup(property, "expired_object_delete_marker", false)
    }
    }
  ]
}


module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 20.37.0"

  cluster_name            = module.eks.cluster_name
  irsa_oidc_provider_arn  = module.eks.oidc_provider_arn
  enable_v1_permissions   = true
  enable_irsa             = true
  create_instance_profile = true
  create_access_entry     = false
  node_iam_role_additional_policies = merge({
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }, var.additional_cluster_policies)
  tags = var.common_tags
}

# POST EKS INSTALL
resource "aws_ssm_parameter" "cluster_endpoint" {
  name  = "/kubernetes/${local.cluster_name}/clusterEndpoint"
  type  = "SecureString"
  value = module.eks.cluster_endpoint
}

resource "aws_ssm_parameter" "cluster_certificate_data" {
  name  = "/kubernetes/${local.cluster_name}/clusterCertificateData"
  type  = "SecureString"
  value = module.eks.cluster_certificate_authority_data
}
