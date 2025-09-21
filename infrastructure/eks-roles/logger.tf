module "eks_log_bucket" {
  count   = var.enable_eks_log_bucket ? 1 : 0
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~>4.2.0"

  bucket                   = local.eks_log_bucket
  acl                      = "private"
  force_destroy            = true
  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
  lifecycle_rule = [for key, property in var.log_bucket_lifecycle_rules : {
    id      = key
    enabled = true
    filter = {
      prefix = property.path
    }
    expiration = {
      days                         = property.expiration_days
      expired_object_delete_marker = lookup(property, "expired_object_delete_marker", false)
    }
    }
  ]
}


resource "aws_iam_policy" "eks_logger" {
  count       = var.enable_eks_log_bucket ? 1 : 0
  name_prefix = "${var.eks_cluster_name}-loki"
  description = "EKS Bucket Logging policy for cluster ${var.eks_cluster_name}"
  policy      = data.aws_iam_policy_document.eks_logger[0].json
}

data "aws_iam_policy_document" "eks_logger" {
  count = var.enable_eks_log_bucket ? 1 : 0
  statement {
    sid    = "AllowBucketLogging"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
    ]

    resources = [
      module.eks_log_bucket[0].s3_bucket_arn,
      "${module.eks_log_bucket[0].s3_bucket_arn}/*"
    ]
  }
}
