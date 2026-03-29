<!-- DO NOT UPDATE: Document auto-generated! -->
# AWS EKS Terraform Module

This module provisions an [Amazon Elastic Kubernetes Service (EKS)](https://aws.amazon.com/eks/) cluster on AWS.

The following resources are created as part of the module:
- EKS Cluster: Managed Kubernetes control plane.
- Node Groups: Managed or self-managed worker nodes.
- IAM Roles and Policies: Configured for cluster, node group, and Kubernetes integration.
- VPC Endpoints: Optional private access for clusters with public endpoint disabled.
- Cluster Add-ons: Core DNS, VPC CNI, kube-proxy, and AWS EBS CSI driver.
- Security Groups: Configured for cluster and node group communication.
- S3 Logging Bucket: Optional centralized storage for EKS logging.
- KMS Encryption: Enabled for cluster secrets and node group storage.

This module also supports creating fully private clusters, managing AWS Auth for RBAC, and deploying additional integrations such as Karpenter and Helm deployers.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.10 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

## Usage
To use this module in your Terraform environment, include it in your Terraform configuration with the necessary parameters. Below is an example of how to use this module:

```hcl
# EKS cluster with a managed node group.
# The VPC module is referenced as a local relative path dependency.

# --- Dependencies ---

module "vpc" {
  source      = "./../../vpc"
  environment = "dev"
  customer    = "example-customer"
  vpc_cidr    = "10.0.0.0/16"
  common_tags = { Name = "example-customer-dev", Environment = "dev" }
}

# --- EKS Cluster ---

module "eks" {
  source = "../"

  environment     = "dev"
  customer        = "example-customer"
  cluster_version = "1.31" # update to the latest supported EKS version as needed
  common_tags     = { Name = "example-customer-dev", Environment = "dev" }

  # Networking — wired from VPC dependency
  vpc_id                               = module.vpc.vpc_id
  subnets                              = module.vpc.private_subnets
  route_table_ids                      = module.vpc.private_route_table_ids
  node_security_group_additional_rules = {}

  # Cluster API endpoint access
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"] # restrict to your corporate egress IPs in production

  # Node groups
  node_groups_attributes = {
    general = {
      name                    = "example-customer-dev-general"
      instance_types          = ["t3a.medium"] # right-size for your workloads
      capacity_type           = "ON_DEMAND"
      ami_type                = "AL2_x86_64"
      taints                  = []
      max_size                = 5
      min_size                = 1
      desired_size            = 2
      disk_size               = 50
      subnet_ids              = module.vpc.private_subnets
      pre_bootstrap_user_data = ""
    }
  }
}
```

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_ebs_csi_iam_service_account"></a> [aws\_ebs\_csi\_iam\_service\_account](#module\_aws\_ebs\_csi\_iam\_service\_account) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts | ~> 6.0 |
| <a name="module_ebs_kms_key"></a> [ebs\_kms\_key](#module\_ebs\_kms\_key) | terraform-aws-modules/kms/aws | ~> 4.0 |
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | ~> 21.0 |
| <a name="module_eks_log_bucket"></a> [eks\_log\_bucket](#module\_eks\_log\_bucket) | terraform-aws-modules/s3-bucket/aws | ~> 5.0 |
| <a name="module_karpenter"></a> [karpenter](#module\_karpenter) | terraform-aws-modules/eks/aws//modules/karpenter | ~> 21.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.aws_ebs_csi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_kms_key.gp3_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_ssm_parameter.cluster_certificate_data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.cluster_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.aws_ebs_csi_driver_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_cluster_policies"></a> [additional\_cluster\_policies](#input\_additional\_cluster\_policies) | Additional Policies to attach to the EKS Cluster | `map(any)` | `{}` | no |
| <a name="input_assume_role_arn"></a> [assume\_role\_arn](#input\_assume\_role\_arn) | Terraform Role to Assume | `string` | `""` | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Indicates whether or not the Amazon EKS public API server endpoint is enabled, set to False to enable only private access via VPN | `bool` | `true` | no |
| <a name="input_cluster_endpoint_public_access_cidrs"></a> [cluster\_endpoint\_public\_access\_cidrs](#input\_cluster\_endpoint\_public\_access\_cidrs) | List of CIDR blocks which can access the Amazon EKS public API server endpoint | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | AWS EKS Cluster Version | `string` | `"1.25"` | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | (Required) Resource Tag | `map(any)` | n/a | yes |
| <a name="input_customer"></a> [customer](#input\_customer) | (Required) Name of Customer. ex: Fiter | `string` | n/a | yes |
| <a name="input_disable_api_termination"></a> [disable\_api\_termination](#input\_disable\_api\_termination) | If true, enables termination protection on the EKS cluster EC2 instances | `bool` | `true` | no |
| <a name="input_eks_logging_bucketname"></a> [eks\_logging\_bucketname](#input\_eks\_logging\_bucketname) | AWS Bucket Name to Send EKS Logs | `string` | `"eks-logs"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | (Required) Environment e.g Dev, Stg, Prod | `string` | n/a | yes |
| <a name="input_helm_deploy"></a> [helm\_deploy](#input\_helm\_deploy) | Create Helm Deployment User in Cluster | `bool` | `false` | no |
| <a name="input_kms_key_rotation_days"></a> [kms\_key\_rotation\_days](#input\_kms\_key\_rotation\_days) | Number of days to rotate the KMS key for EKS managed node group volume encryption | `number` | `365` | no |
| <a name="input_log_bucket_lifecycle_rules"></a> [log\_bucket\_lifecycle\_rules](#input\_log\_bucket\_lifecycle\_rules) | Number of days to retain the logs in the bucket | <pre>map(object({<br/>    path            = string<br/>    expiration_days = number<br/>  }))</pre> | <pre>{<br/>  "logs": {<br/>    "expiration_days": 90,<br/>    "path": "loki_logs/"<br/>  }<br/>}</pre> | no |
| <a name="input_node_groups_attributes"></a> [node\_groups\_attributes](#input\_node\_groups\_attributes) | Node Group Properties. Used to Provision EKS node groups | `map(any)` | n/a | yes |
| <a name="input_node_security_group_additional_rules"></a> [node\_security\_group\_additional\_rules](#input\_node\_security\_group\_additional\_rules) | Additional Rules for Node Security Group | `map(any)` | `{}` | no |
| <a name="input_route_table_ids"></a> [route\_table\_ids](#input\_route\_table\_ids) | Route Table ID for the s3 gateway endpoint if privake only cluster is used | `list(string)` | `[]` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | A list of subnet IDs where the nodes/node groups will be provisioned. | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where the cluster security group will be provisioned | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | value of the cluster ARN |
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | n/a |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | n/a |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | value of the cluster name |
| <a name="output_cluster_oidc_issuer_url"></a> [cluster\_oidc\_issuer\_url](#output\_cluster\_oidc\_issuer\_url) | value of the cluster OIDC issuer URL |
| <a name="output_eks_log_bucket_arn"></a> [eks\_log\_bucket\_arn](#output\_eks\_log\_bucket\_arn) | value of the EKS log bucket ARN |
| <a name="output_eks_log_bucket_name"></a> [eks\_log\_bucket\_name](#output\_eks\_log\_bucket\_name) | value of the EKS log bucket name |
| <a name="output_karpenter_instance_profile"></a> [karpenter\_instance\_profile](#output\_karpenter\_instance\_profile) | value of the Karpenter instance profile name |
| <a name="output_karpenter_queue_name"></a> [karpenter\_queue\_name](#output\_karpenter\_queue\_name) | value of the Karpenter queue name |
| <a name="output_karpenter_role_arn"></a> [karpenter\_role\_arn](#output\_karpenter\_role\_arn) | value of the Karpenter IAM role ARN |
| <a name="output_managed_group"></a> [managed\_group](#output\_managed\_group) | value of the managed node group |
| <a name="output_node_security_group_id"></a> [node\_security\_group\_id](#output\_node\_security\_group\_id) | value of the node security group ID |
| <a name="output_node_security_group_ids"></a> [node\_security\_group\_ids](#output\_node\_security\_group\_ids) | value of the node security group ID |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | value of the OIDC provider ARN |
<!-- End of Document -->