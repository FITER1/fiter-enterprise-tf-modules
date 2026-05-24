# S3 bucket with versioning enabled (default) and private ACL.

module "app_assets" {
  source = "../"

  bucket_name   = "example-customer-dev-app-assets" # must be globally unique
  create_bucket = true                              # set to false to manage the bucket lifecycle externally

  tags = {
    Name        = "example-customer-dev-app-assets"
    Environment = "dev"
    ManagedBy   = "terraform"
  }

  # bucket_acl        = "private"      # default; change to "public-read" for static site hosting
  # enable_versioning = true           # default; set to false if versioning is not needed
  # force_destroy     = true           # default; set to false to prevent accidental deletion in production
}

module "app_assets_with_writer" {
  source = "../"

  bucket_name       = "example-customer-dev-app-assets-writer"
  create_bucket     = true
  enable_iam_writer = true
  iam_user_tags = {
    Purpose = "upload"
  }

  tags = {
    Name        = "example-customer-dev-app-assets-writer"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
