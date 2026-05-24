output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket."
  value       = module.s3_bucket.s3_bucket_arn
}

output "s3_bucket_id" {
  description = "The name/id of the S3 bucket."
  value       = module.s3_bucket.s3_bucket_id
}

output "s3_bucket_domain_name" {
  description = "The bucket domain name."
  value       = module.s3_bucket.s3_bucket_bucket_domain_name
}

output "iam_writer_user_name" {
  description = "The IAM writer user name, when enabled."
  value       = module.writer.name
}

output "iam_writer_user_arn" {
  description = "The IAM writer user ARN, when enabled."
  value       = module.writer.arn
}

output "iam_writer_access_key_id" {
  description = "The IAM writer access key ID, when enabled."
  value       = module.writer.access_key_id
  sensitive   = true
}

output "iam_writer_secret_arn" {
  description = "The Secrets Manager secret ARN containing the IAM writer credentials, when enabled."
  value       = try(aws_secretsmanager_secret.writer[0].arn, null)
}

output "iam_writer_secret_name" {
  description = "The Secrets Manager secret name containing the IAM writer credentials, when enabled."
  value       = try(aws_secretsmanager_secret.writer[0].name, null)
}
