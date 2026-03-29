# ArgoCD deployed via Helm with a single Git repository and one root application.

module "argocd" {
  source = "../"

  argocd_enabled   = true
  eks_cluster_name = "example-customer-dev"  # change to your EKS cluster name
  aws_region       = "eu-west-1"             # change to your AWS region
  argocd_domain    = "argocd.dev.example.io" # change to your ArgoCD hostname

  argocd_version         = "7.6.12"
  argocd_server_replicas = 1

  environment = "dev"

  argocd_repos = {
    apps = {
      type     = "git"
      url      = "https://github.com/example-org/argocd-apps.git" # change to your GitOps repo
      username = "argocd-token"                                   # GitHub username or token name
      password = "gh-token-here"                                  # use a secret or variable in real usage
    }
  }

  argocd_root_applications = [
    {
      app_name       = "bootstrap-addons"
      repository_url = "https://github.com/example-org/argocd-apps.git"
      repo_path      = "bootstrap/addons"
      branch         = "main"
    }
  ]

  # Notifications (optional)
  enable_argocd_notifications = false
  # slack_token               = var.slack_token
}
