module "argocd" {
  source = "../"

  argocd_role_arn             = "arn:::iam::123456789012:role/argocd-role"
  argocd_domain               = "appset.dev.example.io"
  argocd_server_replicas      = 1
  argocd_server_pdb_enabled   = true
  argocd_server_min_pdb       = 2
  aws_region                  = "us-west-2"
  eks_cluster_name            = "example-cluster"
  enable_argocd_notifications = false
  environment                 = "dev"
  cluster_annotations         = {}
  cluster_labels              = { enable_cert_manager = true }

  argocd_repos = {
    repo1 = {
      type         = "git"
      ssh_key      = ""
      username     = "argocd-token"
      password     = "gh-token-password"
      url          = "http://github.com/seyio/argocd-apps.git"
      generate_ssh = false
    }
  }

  argocd_root_applications = [
    {
      app_name       = "bootstrap-addons"
      repository_url = "http://github.com/seyio/argocd-apps.git"
      repo_path      = "argocd_gitops/bootstrap/addons"
      branch         = "main"
  }]
}
