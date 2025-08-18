terraform {
  required_version = ">= 1.0"

  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.7"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
