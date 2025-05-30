terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.47"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.7.1"
    }
  }
}
