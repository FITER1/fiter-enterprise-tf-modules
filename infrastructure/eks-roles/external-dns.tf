# ------------------------------------------------------------------------------
# IAM Assumable roles for DNS service
# ------------------------------------------------------------------------------
resource "aws_iam_policy" "external_dns" {
  count       = var.enable_external_dns ? 1 : 0
  name_prefix = "${var.eks_cluster_name}-extDNS"
  description = "EKS external-dns policy for cluster ${var.eks_cluster_name}"
  policy      = data.aws_iam_policy_document.external_dns[0].json
}

data "aws_iam_policy_document" "external_dns" {
  count = var.enable_external_dns ? 1 : 0
  statement {
    sid    = "ExternalDNSChange"
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets",
    ]

    resources = [for zone in var.hosted_zones : "arn:aws:route53:::hostedzone/${zone}"]
  }

  statement {
    sid    = "ExternalDNSList"
    effect = "Allow"

    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
    ]

    resources = ["*"]
  }
}
