variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string

}


variable "create_bucket" {
  description = "Whether to create the S3 bucket"
  type        = bool
  default     = false
}

variable "bucket_acl" {
  description = "The canned ACL to apply to the S3 bucket"
  type        = string
  default     = "private"
}


variable "tags" {
  description = "A map of tags to apply to the S3 bucket"
  type        = map(string)

}

variable "bucket_ownership" {
  description = "Whether to control ownership of objects in the bucket"
  type        = string
  default     = "ObjectWriter"

}


variable "enable_versioning" {
  description = "Whether to enable bucket versioning"
  type        = bool
  default     = true

}


variable "control_object_ownership" {
  description = "value to control object ownership"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error"
  type        = bool
  default     = true
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket."
  type        = bool
  default     = null
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket."
  type        = bool
  default     = null
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket."
  type        = bool
  default     = null
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket."
  type        = bool
  default     = null
}

variable "enable_iam_writer" {
  description = "Create a dedicated IAM user with object R/W permissions on this bucket; store generated access keys in Secrets Manager."
  type        = bool
  default     = false
}

variable "iam_user_name_override" {
  description = "Override derived IAM user name. IAM user names are unique account-wide."
  type        = string
  default     = ""
}

variable "iam_policy_name_override" {
  description = "Override derived IAM policy name. Renaming an existing policy forces replace."
  type        = string
  default     = ""
}

variable "secret_name_override" {
  description = "Override derived Secrets Manager secret name."
  type        = string
  default     = ""
}

variable "iam_user_tags" {
  description = "Tags merged on top of var.tags for the IAM user only."
  type        = map(string)
  default     = {}
}

variable "secret_recovery_window_in_days" {
  description = "Recovery window for the Secrets Manager secret. Set to 0 in dev/test to allow immediate destroy+recreate."
  type        = number
  default     = 7
}

variable "secret_kms_key_id" {
  description = "Optional KMS CMK ARN/ID for the Secrets Manager secret. Defaults to AWS-managed aws/secretsmanager."
  type        = string
  default     = null
}
