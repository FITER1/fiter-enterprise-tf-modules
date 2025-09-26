/*
 * # tf-backend
 *
 * This Terraform module provisions the required resources for configuring a reliable backend. [Terraform Backend Configuration](https://developer.hashicorp.com/terraform/language/backend)
 * 
 * An Amazon S3 bucket is created to securely store the Terraform state file, ensuring high durability and availability. 
 * by multiple users or processes. This setup ensures consistency, security, and efficient collaboration in infrastructure management.
 *
*/
data "aws_caller_identity" "current" {}

# S3 backend common TF bucket
resource "aws_s3_bucket" "tf_bucket" {
  force_destroy = true
  bucket        = var.bucket_name

  # We explicitly prevent destruction using terraform. Remove this only if you really know what you're doing!
  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name = var.bucket_name
  }
}

resource "aws_s3_bucket_acl" "tf_bucket" {
  bucket     = aws_s3_bucket.tf_bucket.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.tf_bucket.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_versioning" "tf_bucket" {
  bucket = aws_s3_bucket.tf_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_bucket" {
  bucket = aws_s3_bucket.tf_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tf_bucket" {
  bucket                  = aws_s3_bucket.tf_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "tf_bucket" {
  statement {
    sid     = "TerraformBackendBucketPolicy"
    effect  = "Allow"
    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.tf_bucket.arn,
      "${aws_s3_bucket.tf_bucket.arn}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = var.tf_backend_iam_principals
    }
  }
}

resource "aws_s3_bucket_policy" "tf_bucket" {
  count  = length(var.tf_backend_iam_principals) > 0 ? 1 : 0
  bucket = aws_s3_bucket.tf_bucket.id
  policy = data.aws_iam_policy_document.tf_bucket.json

  lifecycle {
    create_before_destroy = true
  }
}
