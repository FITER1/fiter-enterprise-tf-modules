# S3 bucket for storing Terraform remote state with versioning,
# AES256 encryption, public access blocked, and private ACL.

data "aws_caller_identity" "current" {}

module "tf_backend" {
  source      = "../"
  bucket_name = "example-customer-terraform-state" # must be globally unique; typically <org>-<env>-terraform-state

  # IAM principals that are allowed full s3:* access to the state bucket.
  # Add the ARN of the role(s) used to run Terraform (e.g. your CI deploy role).
  # Leave empty to skip creating a bucket policy.
  tf_backend_iam_principals = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/example-customer-ghdeploy-role-terraform", # change to your deploy role name
  ]
}
