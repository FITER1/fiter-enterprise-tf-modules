/**
 * # Secrets Generator Module
 * This Terraform module is responsible for generating secrets for the infrastructure.
 * It is designed to be reusable and can be integrated into various parts of the infrastructure
 * to ensure that secrets are consistently and securely generated.
 * 
 * The module will output the generated secrets which can be used in other parts of your infrastructure.
 *
*/

data "aws_caller_identity" "current" {}

locals {
  secret_readers = length(var.secret_reader_arns) == 0 ? ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"] : var.secret_reader_arns
}

module "secrets_manager" {
  for_each = var.secrets
  source   = "terraform-aws-modules/secrets-manager/aws"
  version  = "~> 1.3.0"

  # Secret
  name                    = "kubernetes/${var.clustername}/${each.key}"
  description             = "Generated ${each.key} Secret"
  recovery_window_in_days = 7

  # Policy
  create_policy       = true
  block_public_policy = true
  policy_statements = {
    read = {
      sid = "AllowAccountRead"
      principals = [{
        type        = "AWS"
        identifiers = local.secret_readers
      }]
      actions   = ["secretsmanager:GetSecretValue"]
      resources = ["*"]
    }
  }

  # Version
  create_random_password           = true
  random_password_length           = each.value.passwordLength
  random_password_override_special = each.value.overridesSpecialChar

  tags = var.common_tags
}
