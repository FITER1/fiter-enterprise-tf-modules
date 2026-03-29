# IAM role for Terraform deployments, plus optional per-pipeline CI/CD roles.
# The deployment role trusts the account root and gets a broad policy covering
# the services Terraform needs to manage (EC2, RDS, EKS, S3, IAM, etc.).

module "gh_actions_iam_role" {
  source = "../"

  deployment_role_name = "example-customer" # change to your project/customer name; roles are named <name>-terraform

  # create_admin_role = true (default) — creates the <deployment_role_name>-terraform role.
  # Set to false if you only want to create the ci_pipelines_roles below.

  # Optional: create per-pipeline CI/CD roles using OIDC trust policies.
  # Each entry requires two policy files checked into your repo:
  #   trustjson:      path (relative to the module root) to an IAM trust policy JSON template
  #   permissionfile: path to an IAM permissions policy JSON template
  #   envvars:        optional map of variables expanded inside the template files via templatefile()
  #
  # ci_pipelines_roles = {
  #   deploy = {
  #     trustjson      = "policies/github-oidc-trust.json"
  #     permissionfile = "policies/deploy-permissions.json"
  #     envvars        = {
  #       account_id = "123456789012"  # change to your AWS account ID
  #       repo       = "example-org/example-repo"
  #     }
  #   }
  # }
}
