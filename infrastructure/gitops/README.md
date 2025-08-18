<!-- DO NOT UPDATE: Document auto-generated! -->
# AWS GitOps Terraform Module

This module sets up ArgoCD on an EKS cluster using Helm.

## Features:
- Creating Helm releases for ArgoCD and its applications.
- Configuring Kubernetes secrets for clusters and repositories.
- Generating SSH keys for repositories if needed.
- Storing public SSH keys in AWS SSM Parameter Store.
- Optionally configuring Slack notifications for ArgoCD.

## Resources:
- Helm Releases.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.7 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Usage
To use this module in your Terraform environment, include it in your Terraform configuration with the necessary parameters. Below is an example of how to use this module:

```hcl
module "argocd" {
  source = "../"

  argocd_role_arn             = "arn:::iam::123456789012:role/argocd-role"
  argocd_domain               = "appset.dev.example.io"
  argocd_server_replicas      = 1
  argocd_server_pdb_enabled   = true
  argocd_server_min_pdb       = 2
  aws_region                  = "us-west-2"
  eks_cluster_name            = "example-cluster"
  enable_argocd_notifications = false
  environment                 = "dev"
  cluster_annotations         = {}
  cluster_labels              = { enable_cert_manager = true }

  argocd_repos = {
    repo1 = {
      type         = "git"
      ssh_key      = ""
      username     = "argocd-token"
      password     = "gh-token-password"
      url          = "http://github.com/seyio/argocd-apps.git"
      generate_ssh = false
    }
  }

  argocd_root_applications = [
    {
      app_name       = "bootstrap-addons"
      repository_url = "http://github.com/seyio/argocd-apps.git"
      repo_path      = "argocd_gitops/bootstrap/addons"
      branch         = "main"
  }]
}
```

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.argocd_public_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [helm_release.argoapps](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.argocd](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_secret.argo_notification_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_secret_v1.argocd_clients](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.argocd_repositories](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.default_cluster](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [tls_private_key.argocdsshkey](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_argo_ingress_class"></a> [argo\_ingress\_class](#input\_argo\_ingress\_class) | Argocd Ingress Class to Use | `string` | `"nginx"` | no |
| <a name="input_argoapps_version"></a> [argoapps\_version](#input\_argoapps\_version) | Version of argocd app helm chart | `string` | `"2.0.2"` | no |
| <a name="input_argocd_clients"></a> [argocd\_clients](#input\_argocd\_clients) | List of Argocd Clients containing name and Client Role | `map(any)` | `{}` | no |
| <a name="input_argocd_domain"></a> [argocd\_domain](#input\_argocd\_domain) | Argocd Host Domain | `string` | n/a | yes |
| <a name="input_argocd_enabled"></a> [argocd\_enabled](#input\_argocd\_enabled) | Deploy Argocd Helm | `bool` | `false` | no |
| <a name="input_argocd_ingress_enabled"></a> [argocd\_ingress\_enabled](#input\_argocd\_ingress\_enabled) | Enable Argocd Ingress | `bool` | `false` | no |
| <a name="input_argocd_repos"></a> [argocd\_repos](#input\_argocd\_repos) | List of Repository containing githuburl, name and type | <pre>map(object({<br/>    type         = string<br/>    ssh_key      = optional(string, "")<br/>    url          = string<br/>    generate_ssh = optional(bool, false)<br/>    username     = optional(string, "")<br/>    password     = optional(string, "")<br/>  }))</pre> | `{}` | no |
| <a name="input_argocd_role_arn"></a> [argocd\_role\_arn](#input\_argocd\_role\_arn) | Argocd Service Account Role Arn | `string` | `""` | no |
| <a name="input_argocd_root_applications"></a> [argocd\_root\_applications](#input\_argocd\_root\_applications) | List of Root Applications to Deploy | `list(any)` | `[]` | no |
| <a name="input_argocd_server_min_pdb"></a> [argocd\_server\_min\_pdb](#input\_argocd\_server\_min\_pdb) | minimum number of allowed available pods when pdb is enabled | `number` | `1` | no |
| <a name="input_argocd_server_pdb_enabled"></a> [argocd\_server\_pdb\_enabled](#input\_argocd\_server\_pdb\_enabled) | enable pod pdb for rapid scaling environments, ensure replicas is over one to enable pdb | `bool` | `false` | no |
| <a name="input_argocd_server_replicas"></a> [argocd\_server\_replicas](#input\_argocd\_server\_replicas) | number of replicas for argpcd server | `number` | `1` | no |
| <a name="input_argocd_set_values"></a> [argocd\_set\_values](#input\_argocd\_set\_values) | Arguement for setting Values in Helm Chart that are not passed in the values files | `list(any)` | `[]` | no |
| <a name="input_argocd_users"></a> [argocd\_users](#input\_argocd\_users) | List of Users to add to Argocd | <pre>map(object({<br/>    role = string<br/>  }))</pre> | `{}` | no |
| <a name="input_argocd_version"></a> [argocd\_version](#input\_argocd\_version) | Version of Argocd Helm to Use | `string` | `"7.6.12"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region to Where ECR Registry Resides | `string` | n/a | yes |
| <a name="input_cluster_annotations"></a> [cluster\_annotations](#input\_cluster\_annotations) | Annotations to add to argocd cluster secret | `map(any)` | `{}` | no |
| <a name="input_cluster_labels"></a> [cluster\_labels](#input\_cluster\_labels) | Labels to add to argocd cluster secret | `map(any)` | `{}` | no |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | Name of Kubernetes Cluster. Note. change to Cluster | `string` | n/a | yes |
| <a name="input_enable_argocd_notifications"></a> [enable\_argocd\_notifications](#input\_enable\_argocd\_notifications) | Enable Argocd Notification | `bool` | `false` | no |
| <a name="input_enable_ui_exec"></a> [enable\_ui\_exec](#input\_enable\_ui\_exec) | Enable Exec through argocd UI | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment Prod, Development or staging | `string` | `"dev"` | no |
| <a name="input_ingress_cert_issuer"></a> [ingress\_cert\_issuer](#input\_ingress\_cert\_issuer) | Cluster Issuer for Cert Manager to be used. Allows for custom | `string` | `"letsencrypt-prod-issuer"` | no |
| <a name="input_ingress_class_name"></a> [ingress\_class\_name](#input\_ingress\_class\_name) | Ingress Class Name for Argocd Ingress | `string` | `"nginx"` | no |
| <a name="input_ingress_tls_enabled"></a> [ingress\_tls\_enabled](#input\_ingress\_tls\_enabled) | Enable Ingress TLS | `bool` | `true` | no |
| <a name="input_k8s_namespace"></a> [k8s\_namespace](#input\_k8s\_namespace) | Namespace to Deploy Argocd | `string` | `"argocd"` | no |
| <a name="input_projects"></a> [projects](#input\_projects) | List of Projects to Deploy | <pre>list(object({<br/>    project_name          = string<br/>    project_description   = string<br/>    destination_namespace = optional(string, "*")<br/>    destination_server    = optional(string, "https://kubernetes.default.svc")<br/>  }))</pre> | `[]` | no |
| <a name="input_set_values_argocd_helm"></a> [set\_values\_argocd\_helm](#input\_set\_values\_argocd\_helm) | List of Set Command to Pass to Prometheus Helm Install | `list(any)` | `[]` | no |
| <a name="input_slack_token"></a> [slack\_token](#input\_slack\_token) | Slack Token to Send Notifications | `string` | `""` | no |

## Outputs

No outputs.
<!-- End of Document -->