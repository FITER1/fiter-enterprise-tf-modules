module "eks_argocd_client" {
  source          = "../"
  policy_file     = "argocd_client_role.json"
  customer        = "revving"
  role_name       = "argocd_client_role"
  environment     = "dev"
  common_tags     = { "Owner" = "revving", "Environment" = "dev" }
  assume_role_arn = "arn:aws:iam::12345678:role/example_name"
}
