variable "cluster_autoscaler_enabled" {
  default     = false
  description = "Enable Cluster Autoscaler in Cluster"
  type        = bool
}

variable "cluster_autoscaler_version" {
  default     = "9.27.0"
  description = "Helm Chart Version for Cluster Autoscaler"
  type        = string
}

variable "metric_server_enabled" {
  default     = false
  description = "Enable Cluster Metrics Server"
  type        = bool
}

variable "metrics_server_version" {
  default     = "6.6.4"
  description = "Helm Chart Version for Metrics Server"
  type        = string
}

variable "cert_manager_enabled" {
  default     = false
  description = "Enable Cert Manager In Cluster, Not Needed if Running ALB Ingress"
  type        = bool
}

variable "cert_manager_version" {
  default     = "v1.13.2"
  description = "Helm Chart Version for Cert Manager"
  type        = string
}

variable "enable_cluster_issuer" {
  default     = false
  description = "Enable Cluster Issuer for Cert Manager"
  type        = bool
}

variable "nginx_ingress_enabled" {
  default     = false
  description = "Enable Nginx Ingress Controller Chart"
  type        = bool
}

variable "nginx_ingress_version" {
  default     = "4.13.0"
  description = "Helm Chart Version for Nginx Ingress Controller"
  type        = string
}

variable "alb_ingress_enabled" {
  default     = false
  description = "Enable AWS Application Load Balancer Ingress Controller (Specific to EKS Clusters)"
  type        = bool
}

variable "alb_ingress_version" {
  default     = "1.7.0"
  description = "Helm Chart Version for AWS Application LoadBalancer Controller"
  type        = string
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to Deploy Loadbalancer for ALB ingress (Specific to AWS)"
}

variable "eks_cluster_name" {
  type        = string
  description = "Name of Kubernetes Cluster. Note. change to Cluster"
}

variable "enable_gp3_storage" {
  default     = false
  description = "Enable AWS GP3 Storage, Specific to EKS"
  type        = bool
}

variable "external_secret_enabled" {
  default     = false
  description = "Enable External Secrets Helm Release"
  type        = bool
}

variable "external_secret_version" {
  default     = "0.9.9"
  description = "Helm Version of External Secrets"
  type        = string
}

variable "service_account_arns" {
  description = "Map of Arns from Service Accounts Module"
  type        = map(string)
  default     = {}
}

variable "external_aws_secret_parameter_store_enabled" {
  default     = false
  description = "Enable AWS Parameter Store Integration"
  type        = bool
}

variable "external_aws_secret_manager_store_enabled" {
  default     = false
  description = "Enable AWS Secret Manager Store Integration"
  type        = bool
}

variable "external_secrets_namespace" {
  default     = "kube-system"
  description = "Kubernetes Namespace to Deploy External Secrets"
  type        = string
}

variable "metrics_server_resources" {
  type        = map(any)
  description = "Resources and Limits for Metrics Server Pod"
  default = {
    cpu_request = "100m"
    cpu_limit   = "200m"
    mem_request = "100Mi"
    mem_limit   = "300Mi"
  }
}

variable "external_secret_resources" {
  type        = map(any)
  description = "Resources and Limits for External Secrets Pod"
  default = {
    cpu_request = "100m"
    mem_request = "200Mi"
  }
}

variable "cert_manager_resources" {
  type        = map(any)
  description = "Resources and Limits for Cert Manager Pod"
  default = {
    cpu_request = "100m"
    cpu_limit   = "200m"
    mem_request = "100Mi"
    mem_limit   = "300Mi"
  }
}

variable "alb_resources" {
  type        = map(any)
  description = "Resources and Limits for ALB Controller Pod"
  default = {
    cpu_request = "200m"
    mem_request = "200Mi"
  }
}

variable "additional_helm_charts" {
  type        = map(any)
  description = "Map of additional Charts to create"
  default     = {}
}

variable "nginx_ingress_resources" {
  type        = map(any)
  description = "Additional configurations for nginx-ingress controller"
  default = {
    "internal_load_balancer" : "false"
  }

}


variable "cname_records" {
  description = "List of CNAME records to create in the private zone"
  type        = list(map(string))
  default = [
    {
      name  = "argocd"
      value = "argocd.fineract.internal"
      ttl   = 300
    },
    {
      name  = "uat"
      value = "uat.fineract.internal"
      ttl   = 300
    },
    {
      name  = "monitoring"
      value = "monitoring.fineract.internal"
      ttl   = 300
    }

  ]

}

variable "enable_private_zone" {
  description = "Enable Private Route53 Zone"
  type        = bool
  default     = false
}

variable "private_zone_host_name" {
  description = "Private Route53 Zone Host Name"
  type        = string
  default     = "fineract.internal"
}

variable "nginx_ingress_lb_scheme" {
  description = "AWS Loadbalancer Scheme, can be `internet-facing` or `internal`"
  type        = string
  default     = "internet-facing"
}

variable "mysql_operator_enabled" {
  description = "Enable Mysql Operator Helm Chart"
  default     = false
  type        = bool
}

variable "mysql_operator_namespace" {
  description = "Namespace to install MySQL Operator"
  default     = "devops"
  type        = string
}

variable "mysql_operator_version" {
  default     = "2.2.1  "
  description = "Helm Chart Version for Mysql"
  type        = string
}

variable "postgres_operator_enabled" {
  description = "Enable Postgres Operator Helm Chart"
  default     = false
  type        = bool
}

variable "postgres_operator_namespace" {
  description = "Namespace to install Postgres Operator"
  default     = "devops"
  type        = string
}

variable "postgres_operator_version" {
  default     = "1.13.0"
  description = "Helm Chart Version for Postgres Operator"
  type        = string
}

variable "kube_downscaler_enabled" {
  description = "Enable Kube Downscaler Helm Chart"
  default     = false
  type        = bool
}

variable "kube_downscaler_namespace" {
  description = "Namespace to install Kube Downscaler"
  default     = "devops"
  type        = string
}

variable "kube_downscaler_version" {
  default     = "0.2.8"
  description = "Helm Chart Version for Kube Downscaler"
  type        = string
}
