
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "4.11.0"

  bucket        = var.bucket_name
  acl           = var.bucket_acl
  create_bucket = var.create_bucket

  control_object_ownership              = var.control_object_ownership
  object_ownership                      = var.bucket_ownership
  force_destroy                         = var.force_destroy
  attach_deny_insecure_transport_policy = true

  versioning = {
    enabled = var.enable_versioning
  }

  tags = var.tags
}
