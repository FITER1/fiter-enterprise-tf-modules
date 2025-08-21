module "secrets" {
  source             = "../../../../terraform-modules/infrastructure/secrets-generator"
  clustername        = "fiter-eks-2"
  secret_reader_arns = ["arn:aws:iam::12345678:role/fiter-dev-eks-external-secrets"] # allowed secrets readers
  secrets = {
    grafana = {
      passwordLength       = 20
      overridesSpecialChar = false
    }
    application_secret = {}
  }
}
