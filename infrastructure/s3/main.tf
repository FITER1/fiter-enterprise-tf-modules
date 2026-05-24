/**
 * Creates an S3 bucket and, when enable_iam_writer is true, also creates a dedicated IAM writer user with generated access keys stored in AWS Secrets Manager for object read/write workflows.
 */

data "aws_partition" "current" {}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.13"

  bucket        = var.bucket_name
  acl           = var.bucket_acl
  create_bucket = var.create_bucket

  block_public_acls                     = var.block_public_acls
  block_public_policy                   = var.block_public_policy
  control_object_ownership              = var.control_object_ownership
  ignore_public_acls                    = var.ignore_public_acls
  object_ownership                      = var.bucket_ownership
  restrict_public_buckets               = var.restrict_public_buckets
  force_destroy                         = var.force_destroy
  attach_deny_insecure_transport_policy = true

  versioning = {
    enabled = var.enable_versioning
  }

  tags = var.tags
}

resource "aws_iam_policy" "writer" {
  count       = var.enable_iam_writer ? 1 : 0
  name        = local.iam_policy_name
  path        = "/"
  description = "R/W access to s3://${var.bucket_name}"
  tags        = var.tags

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:PutObject", "s3:GetObject", "s3:ListBucket", "s3:DeleteObject"]
      Resource = [local.bucket_arn, "${local.bucket_arn}/*"]
    }]
  })
}

module "writer" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "~> 6.6"

  create               = var.enable_iam_writer
  name                 = local.iam_user_name
  create_login_profile = false
  create_access_key    = true
  policies             = var.enable_iam_writer ? { s3_writer = aws_iam_policy.writer[0].arn } : {}
  tags                 = merge(var.tags, var.iam_user_tags)
}

resource "aws_secretsmanager_secret" "writer" {
  count                   = var.enable_iam_writer ? 1 : 0
  name                    = local.secret_name
  recovery_window_in_days = var.secret_recovery_window_in_days
  kms_key_id              = var.secret_kms_key_id
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "writer" {
  count     = var.enable_iam_writer ? 1 : 0
  secret_id = aws_secretsmanager_secret.writer[0].id
  secret_string = jsonencode({
    s3_access_key = module.writer.access_key_id
    s3_secret_key = module.writer.access_key_secret
  })
}
