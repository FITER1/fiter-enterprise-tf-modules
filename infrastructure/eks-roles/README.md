<!-- BEGIN_TF_DOCS -->
# AWS EKS IAM Role and Policy Terraform Module

This module manages AWS IAM roles and policies required for Kubernetes applications running on an [EKS Cluster](https://aws.amazon.com/eks/).

It creates IAM roles for various services and assigns the necessary permissions based on predefined policies.
Additionally, it allows the use of OIDC for secure access to AWS resources from the Kubernetes service accounts.
The module automatically associates the service accounts with the corresponding IAM roles, making it easier to manage permissions at the Kubernetes level.

The IAM policies are generated dynamically based on input policy files and associated with the roles. For additional flexibility, the module supports adding custom policies through the `additional_policies` variable.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

## Usage
To use this module in your Terraform environment, include it in your Terraform configuration with the necessary parameters. Below is an example of how to use this module:

```hcl
# OIDC-based IAM roles for EKS workloads (ALB, ArgoCD, External Secrets, etc.)
# Requires a running EKS cluster — VPC and EKS are included as dependencies.

# --- Dependencies ---

module "vpc" {
  source      = "./../../vpc"
  environment = "dev"
  customer    = "example-customer"
  vpc_cidr    = "10.0.0.0/16"
  common_tags = { Name = "example-customer-dev", Environment = "dev" }
}

module "eks" {
  source          = "./../../eks_cluster"
  environment     = "dev"
  customer        = "example-customer"
  cluster_version = "1.31"
  common_tags     = { Name = "example-customer-dev", Environment = "dev" }

  vpc_id                               = module.vpc.vpc_id
  subnets                              = module.vpc.private_subnets
  route_table_ids                      = module.vpc.private_route_table_ids
  node_security_group_additional_rules = {}

  node_groups_attributes = {
    general = {
      name                    = "example-customer-dev-general"
      instance_types          = ["t3a.medium"]
      capacity_type           = "ON_DEMAND"
      ami_type                = "AL2_x86_64"
      taints                  = []
      max_size                = 3
      min_size                = 1
      desired_size            = 1
      disk_size               = 50
      subnet_ids              = module.vpc.private_subnets
      pre_bootstrap_user_data = ""
    }
  }
}

# --- EKS IAM Roles ---

module "eks_iam_roles" {
  source = "../"

  # Required variables
  eks_cluster_name     = module.eks.cluster_name
  cluster_provider_arn = module.eks.oidc_provider_arn # OIDC provider ARN (not the issuer URL)
  region               = "eu-west-1"                  # change to your AWS region

  # Enable the roles your cluster needs — all default to false except external_secrets and eks_log
  enable_alb_controller     = true  # IAM role for AWS Load Balancer Controller
  enable_argocd             = false # IAM role for ArgoCD (S3/Secrets Manager access)
  enable_cluster_autoscaler = false # IAM role for Cluster Autoscaler
  enable_external_dns       = false # IAM role for External DNS

  # External Secrets operator role (enabled by default)
  eks_external_secret_enabled = true

  # EKS log bucket role (enabled by default)
  enable_eks_log_bucket  = true
  eks_logging_bucketname = "example-customer-dev-eks-logs" # change to your S3 bucket name

  additional_policies = {} # add custom IAM policies for workload-specific service accounts
}
```

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks_iam_role"></a> [eks\_iam\_role](#module\_eks\_iam\_role) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts | ~> 6.0 |
| <a name="module_eks_log_bucket"></a> [eks\_log\_bucket](#module\_eks\_log\_bucket) | terraform-aws-modules/s3-bucket/aws | ~> 4.11.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.argo_cd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.eks_apps_service_account_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.eks_logger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.external_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.external_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.lb_controller](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.argo_cd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.eks_logger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.external_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.external_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_policies"></a> [additional\_policies](#input\_additional\_policies) | Map of Additional Policies, Extending the module | `map(any)` | `{}` | no |
| <a name="input_alb_k8s_namespace"></a> [alb\_k8s\_namespace](#input\_alb\_k8s\_namespace) | (Optional) Kubernetes Namespace for ALB Controller | `string` | `"kube-system"` | no |
| <a name="input_alb_sa_name"></a> [alb\_sa\_name](#input\_alb\_sa\_name) | (Optional) Kubernetes Service Account for ALB Controller | `string` | `"aws-alb-ingress-controller-sa"` | no |
| <a name="input_argocd_k8s_namespace"></a> [argocd\_k8s\_namespace](#input\_argocd\_k8s\_namespace) | (Optional) Kubernetes Namespace for ArgoCd Controller | `string` | `"argocd"` | no |
| <a name="input_argocd_sa_name"></a> [argocd\_sa\_name](#input\_argocd\_sa\_name) | (Optional) Kubernetes Service Account for ArgoCD Controller | `string` | `"*"` | no |
| <a name="input_ca_k8s_namespace"></a> [ca\_k8s\_namespace](#input\_ca\_k8s\_namespace) | (Optional) Kubernetes Namespace for Cluster Autoscaler Controller | `string` | `"kube-system"` | no |
| <a name="input_ca_sa_name"></a> [ca\_sa\_name](#input\_ca\_sa\_name) | (Optional) Kubernetes Service Account for Cluster Autoscaler Controller | `string` | `"cluster-autoscaler-controller-sa"` | no |
| <a name="input_cluster_provider_arn"></a> [cluster\_provider\_arn](#input\_cluster\_provider\_arn) | (Required) OIDC Provider ARN for the Kubernetes Cluster | `string` | n/a | yes |
| <a name="input_ebs_k8s_namespace"></a> [ebs\_k8s\_namespace](#input\_ebs\_k8s\_namespace) | (Optional) Kubernetes Namespace for Cluster Autoscaler Controller | `string` | `"kube-system"` | no |
| <a name="input_ebs_sa_name"></a> [ebs\_sa\_name](#input\_ebs\_sa\_name) | (Optional) Kubernetes Service Account for EBS CSI Controller | `string` | `"ebs-csi-controller-sa"` | no |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | (Required) EKS Cluster Name | `string` | n/a | yes |
| <a name="input_eks_external_secret_enabled"></a> [eks\_external\_secret\_enabled](#input\_eks\_external\_secret\_enabled) | Enable External Secrets IAM Role | `bool` | `true` | no |
| <a name="input_eks_logging_bucketname"></a> [eks\_logging\_bucketname](#input\_eks\_logging\_bucketname) | AWS Bucket Name to Send EKS Logs | `string` | `"eks-logs"` | no |
| <a name="input_enable_alb_controller"></a> [enable\_alb\_controller](#input\_enable\_alb\_controller) | (Optional) Enable Creation of ALB Controller Role | `bool` | `false` | no |
| <a name="input_enable_argocd"></a> [enable\_argocd](#input\_enable\_argocd) | (Optional) Enable Creation of ArgoCD Role | `bool` | `false` | no |
| <a name="input_enable_cluster_autoscaler"></a> [enable\_cluster\_autoscaler](#input\_enable\_cluster\_autoscaler) | (Optional) Enable Creation of Cluster Autoscaler Role | `bool` | `false` | no |
| <a name="input_enable_eks_log_bucket"></a> [enable\_eks\_log\_bucket](#input\_enable\_eks\_log\_bucket) | Enabled EKS Bucket Log Role | `bool` | `true` | no |
| <a name="input_enable_external_dns"></a> [enable\_external\_dns](#input\_enable\_external\_dns) | (Optional) Enable Creation of External DNS Role | `bool` | `false` | no |
| <a name="input_extDNS_k8s_namespace"></a> [extDNS\_k8s\_namespace](#input\_extDNS\_k8s\_namespace) | (Optional) Kubernetes Namespace for External DNS Controller | `string` | `"kube-system"` | no |
| <a name="input_extDNS_sa_name"></a> [extDNS\_sa\_name](#input\_extDNS\_sa\_name) | (Optional) Kubernetes Service Account for External DNS Controller | `string` | `"external-dns-sa"` | no |
| <a name="input_external_secret_sa_name"></a> [external\_secret\_sa\_name](#input\_external\_secret\_sa\_name) | Service Account Name for External Secrets | `string` | `"external-secrets*"` | no |
| <a name="input_hosted_zones"></a> [hosted\_zones](#input\_hosted\_zones) | List of Hosted Zones to be used in External DNS | `list(string)` | `[]` | no |
| <a name="input_log_bucket_lifecycle_rules"></a> [log\_bucket\_lifecycle\_rules](#input\_log\_bucket\_lifecycle\_rules) | Number of days to retain the logs in the bucket | <pre>map(object({<br/>    path            = string<br/>    expiration_days = number<br/>  }))</pre> | <pre>{<br/>  "logs": {<br/>    "expiration_days": 90,<br/>    "path": "loki_logs/"<br/>  }<br/>}</pre> | no |
| <a name="input_monitoring_namespace"></a> [monitoring\_namespace](#input\_monitoring\_namespace) | Monitoring Namespace where Log System is deployed | `string` | `"monitoring"` | no |
| <a name="input_monitoring_sa_name"></a> [monitoring\_sa\_name](#input\_monitoring\_sa\_name) | Service Account Name for EKS logs | `string` | `"eks-log-sa"` | no |
| <a name="input_parameter_store_prefixes"></a> [parameter\_store\_prefixes](#input\_parameter\_store\_prefixes) | List of Parameter Store Prefixes to be used in External Secrets | `list(string)` | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region to deploy the resources | `string` | n/a | yes |
| <a name="input_secret_prefixes"></a> [secret\_prefixes](#input\_secret\_prefixes) | List of Secret Prefixes to be used in External Secrets | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_metadata"></a> [cluster\_metadata](#output\_cluster\_metadata) | n/a |
| <a name="output_eks_log_bucket_name"></a> [eks\_log\_bucket\_name](#output\_eks\_log\_bucket\_name) | n/a |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | n/a |
<!-- END_TF_DOCS -->