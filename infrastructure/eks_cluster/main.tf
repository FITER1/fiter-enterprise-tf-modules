# ------------------------------------------------------------------------------
# eks module
# ------------------------------------------------------------------------------
# support for assume role and other
locals {
  args = var.assume_role_arn == "" ? ["eks", "get-token", "--cluster-name", local.cluster_name] : ["eks", "get-token", "--cluster-name", local.cluster_name, "--role-arn", "${var.assume_role_arn}"]
  interface_endpoints = { for endpoint in var.vpc_interface_endpoints : endpoint => {
    service             = endpoint
    service_type        = "Interface"
    private_dns_enabled = true
    tags = {
      Name = "${endpoint}-vpc-endpoint"
    }
    }
  }

  gateway_endpoint = { for endpoint in var.vpc_gateway_endpoints : endpoint => {
    service      = endpoint
    service_type = "Gateway"
    tags = {
      Name = "${endpoint}-vpc-endpoint"
    }
    route_table_ids = var.route_table_ids
    }
  }

  endpoints = merge(local.interface_endpoints, local.gateway_endpoint)
  kube_deploy_user = var.helm_deploy ? [{
    rolearn  = "arn:aws:iam::${local.account_id}:role/${local.cluster_name}-ghdeploy-role-kube-deploy"
    username = "helm-ci-deployer"
    groups   = ["ci-user"]
  }] : []
}

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
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 19.0"
  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version
  subnet_ids      = var.subnets
  vpc_id          = var.vpc_id
  enable_irsa     = true

  cluster_addons = {
    coredns = merge(
      {
        resolve_conflicts_on_create = "OVERWRITE"
        resolve_conflicts_on_update = "OVERWRITE"
      },
      lookup(var.cluster_addon_versions, "coredns", "") != "" ? { addon_version = var.cluster_addon_versions["coredns"] } : {}
    )
    kube-proxy = merge(
      {
        resolve_conflicts_on_create = "OVERWRITE"
        resolve_conflicts_on_update = "OVERWRITE"
      },
      lookup(var.cluster_addon_versions, "kube-proxy", "") != "" ? { addon_version = var.cluster_addon_versions["kube-proxy"] } : {}
    )
    vpc-cni = merge(
      {
        resolve_conflicts_on_create = "OVERWRITE"
        resolve_conflicts_on_update = "OVERWRITE"
      },
      lookup(var.cluster_addon_versions, "vpc-cni", "") != "" ? { addon_version = var.cluster_addon_versions["vpc-cni"] } : {}
    )
    aws-ebs-csi-driver = merge(
      {
        resolve_conflicts_on_create = "OVERWRITE"
        resolve_conflicts_on_update = "OVERWRITE"
        service_account_role_arn    = module.aws_ebs_csi_iam_service_account.iam_role_arn
      },
      lookup(var.cluster_addon_versions, "aws-ebs-csi-driver", "") != "" ? { addon_version = var.cluster_addon_versions["aws-ebs-csi-driver"] } : {}
    )
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

  create_iam_role = true

  eks_managed_node_groups = {
    for key, value in var.node_groups_attributes :
    key => {
      min_size     = value["min_size"]
      max_size     = value["max_size"]
      desired_size = value["desired_size"]
      disk_size    = value["disk_size"]
      taints       = lookup(value, "taints", [])
      subnet_ids   = lookup(value, "subnet_ids", var.subnets)

      instance_types          = value["instance_types"]
      capacity_type           = value["capacity_type"]
      pre_bootstrap_user_data = lookup(value, "pre_bootstrap_user_data", "")
    }
  }

  iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  }
  # Allow Extending without making module changes
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

  manage_aws_auth_configmap = true

  aws_auth_roles = local.eks_auth_roles

  aws_auth_users = local.eks_auth_users
}

# add support for fully private clusters
module "endpoints" {
  count                 = var.cluster_endpoint_public_access ? 0 : 1
  source                = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version               = "5.2.0"
  vpc_id                = var.vpc_id
  create_security_group = false
  security_group_ids    = [module.eks.node_security_group_id, module.eks.cluster_security_group_id]
  subnet_ids            = var.subnets
  endpoints             = local.endpoints
}

module "ebs_kms_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 1.5"

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
  version                       = "5.28.0"
  create_role                   = true
  role_name                     = "${local.prefix}-aws-ebs-csi"
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.aws_ebs_csi.arn, "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

module "eks_log_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.1"
  bucket = format(
    "%s-%s-%s",
    var.eks_logging_bucketname,
    local.cluster_name,
    data.aws_caller_identity.current.account_id
  )
  acl           = "private"
  force_destroy = true

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}


module "karpenter" {
  source                 = "terraform-aws-modules/eks/aws//modules/karpenter"
  version                = "19.20.0"
  cluster_name           = module.eks.cluster_name
  irsa_oidc_provider_arn = module.eks.oidc_provider_arn

  policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  irsa_tag_key    = "karpenter.sh/managed-by"
  irsa_tag_values = [local.cluster_name]
  tags            = var.common_tags
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

module "eks-kubeconfig" {
  source  = "hyperbadger/eks-kubeconfig/aws"
  version = "1.0.0"

  depends_on = [module.eks]
  cluster_id = module.eks.cluster_name
}

resource "local_file" "kubeconfig" {
  content  = module.eks-kubeconfig.kubeconfig
  filename = "kubeconfig-${local.cluster_name}"
  lifecycle {
    ignore_changes = all
  }
}

data "external" "os" {
  program = ["sh", "${path.cwd}/get_os.sh"]
}

resource "null_resource" "custom" {
  count = var.enable_prefix_delegation_hook ? 1 : 0

  triggers = {
    build_number = var.cluster_version
  }

  provisioner "local-exec" {
    command = "wget -q https://storage.googleapis.com/kubernetes-release/release/v${var.cluster_version}.0/bin/${local.os}/$(uname -m)/kubectl && chmod +x kubectl"
  }

  provisioner "local-exec" {
    command = "./kubectl --kubeconfig kubeconfig-${local.cluster_name} set env daemonset aws-node -n kube-system ENABLE_PREFIX_DELEGATION=true && rm -rf kubeconfig-${local.cluster_name}"
  }
  depends_on = [local_file.kubeconfig]
}
