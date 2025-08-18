variable "alb_k8s_namespace" {
  type        = string
  description = "(Optional) Kubernetes Namespace for ALB Controller"
  default     = "kube-system"
}

variable "alb_sa_name" {
  type        = string
  description = "(Optional) Kubernetes Service Account for ALB Controller"
  default     = "aws-alb-ingress-controller-sa"
}

variable "argocd_k8s_namespace" {
  type        = string
  description = "(Optional) Kubernetes Namespace for ArgoCd Controller"
  default     = "argocd"
}

variable "argocd_sa_name" {
  type        = string
  description = "(Optional) Kubernetes Service Account for ArgoCD Controller"
  default     = "*"
}

variable "ca_k8s_namespace" {
  type        = string
  description = "(Optional) Kubernetes Namespace for Cluster Autoscaler Controller"
  default     = "kube-system"
}


variable "ca_sa_name" {
  type        = string
  description = "(Optional) Kubernetes Service Account for Cluster Autoscaler Controller"
  default     = "cluster-autoscaler-controller-sa"
}

# the beginning variable that is not been used in the module
variable "ebs_k8s_namespace" {
  type        = string
  description = "(Optional) Kubernetes Namespace for Cluster Autoscaler Controller"
  default     = "kube-system"
}


variable "ebs_sa_name" {
  type        = string
  description = "(Optional) Kubernetes Service Account for EBS CSI Controller"
  default     = "ebs-csi-controller-sa"
}
variable "extDNS_k8s_namespace" {
  type        = string
  description = "(Optional) Kubernetes Namespace for External DNS Controller"
  default     = "kube-system"
}


variable "extDNS_sa_name" {
  type        = string
  description = "(Optional) Kubernetes Service Account for External DNS Controller"
  default     = "external-dns-sa"
}

# the end variable that is not been used in the module

variable "cluster_oidc_issuer_url" {
  type        = string
  description = "(Required) OIDC URL for the Kubernetes Cluster"
}

variable "enable_alb_controller" {
  type        = bool
  description = "(Optional) Enable Creation of ALB Controller Role"
  default     = false
}

variable "enable_argocd" {
  type        = bool
  description = "(Optional) Enable Creation of ArgoCD Role"
  default     = false
}

variable "enable_cluster_autoscaler" {
  type        = bool
  description = "(Optional) Enable Creation of Cluster Autoscaler Role"
  default     = false
}

variable "enable_external_dns" {
  type        = bool
  description = "(Optional) Enable Creation of External DNS Role"
  default     = false
}

variable "eks_cluster_name" {
  type        = string
  description = "(Required) EKS Cluster Name"
}

variable "eks_log_bucket" {
  type        = string
  description = "Bucket ARN to send EKS Logs"
  default     = ""
}

variable "enable_eks_log_bucket" {
  type        = bool
  description = "Enabled EKS Bucket Log Role"
  default     = true
}

variable "monitoring_namespace" {
  type        = string
  description = "Monitoring Namespace where Log System is deployed"
  default     = "monitoring"
}

variable "monitoring_sa_name" {
  type        = string
  description = "Service Account Name for EKS logs"
  default     = "eks-log-sa"
}

variable "external_secret_sa_name" {
  type        = string
  description = "Service Account Name for External Secrets"
  default     = "external-secrets*"
}

variable "eks_external_secret_enabled" {
  type        = bool
  description = "Enable External Secrets IAM Role"
  default     = true
}

variable "additional_policies" {
  type        = map(any)
  description = "Map of Additional Policies, Extending the module"
  default     = {}
}

variable "region" {
  type        = string
  description = "AWS Region to deploy the resources"
}

variable "secret_prefixes" {
  type        = list(string)
  description = "List of Secret Prefixes to be used in External Secrets"
  default     = []
}

variable "parameter_store_prefixes" {
  type        = list(string)
  description = "List of Parameter Store Prefixes to be used in External Secrets"
  default     = []
}

variable "hosted_zones" {
  type        = list(string)
  description = "List of Hosted Zones to be used in External DNS"
  default     = []
}