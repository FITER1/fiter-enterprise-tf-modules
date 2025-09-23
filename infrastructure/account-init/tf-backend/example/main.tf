
data "aws_caller_identity" "current" {}

module "tf_backend" {
  source      = "../"
  bucket_name = "example_bucket"
  tf_backend_iam_principals = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${example_role}-tf-deploy"
  ]
}
