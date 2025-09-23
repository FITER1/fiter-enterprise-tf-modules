data "aws_caller_identity" "current" {}

module "gh_actions_iam_role" {
  source                   = "../"
  deployment_role_name     = "example_deployment_role_name"
  ci_pipelines_roles       = {}
}