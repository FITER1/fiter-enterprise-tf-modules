# Generates random secrets and stores them in AWS Secrets Manager.
# Secret ARNs are scoped to the cluster name prefix.

module "secrets" {
  source      = "../"
  clustername = "example-customer-dev" # change to your EKS cluster name

  secret_reader_arns = [
    "arn:aws:iam::123456789012:role/example-customer-dev-external-secrets", # change to your External Secrets operator role ARN
  ]

  secrets = {
    grafana = {
      passwordLength       = 24
      overridesSpecialChar = "!#$%&*()-_=+[]{}<>:?" # special chars to include; omit to use the default set
    }
    app_secret = {} # uses default length (32) and default special chars
  }

  common_tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
