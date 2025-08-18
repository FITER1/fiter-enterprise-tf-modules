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
      var.eks_log_bucket,
      "${var.eks_log_bucket}/*"
    ]
  }
}
