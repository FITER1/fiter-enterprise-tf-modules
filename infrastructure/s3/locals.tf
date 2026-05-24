locals {
  iam_user_name   = var.iam_user_name_override != "" ? var.iam_user_name_override : "${var.bucket_name}-writer"
  iam_policy_name = var.iam_policy_name_override != "" ? var.iam_policy_name_override : "${local.iam_user_name}-policy"
  secret_name     = var.secret_name_override != "" ? var.secret_name_override : "s3/${var.bucket_name}/writer"
  bucket_arn      = var.create_bucket ? module.s3_bucket.s3_bucket_arn : "arn:${data.aws_partition.current.partition}:s3:::${var.bucket_name}"
}
