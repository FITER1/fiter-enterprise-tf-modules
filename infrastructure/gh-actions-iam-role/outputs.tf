output "terraform_role_arn" {
  value       = try(aws_iam_role.terraform_role[0].arn, "")
  description = "terraform role arn"
}

output "ci_pipeline_roles" {
  value       = { for k, role in aws_iam_role.ci_roles : k => role.arn }
  description = "CI pipeline roles"
}
