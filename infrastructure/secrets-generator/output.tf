output "secret" {
  description = "Name of Generated Secret"
  value = {
    for key, secret in module.secrets_manager : key => secret.secret_name
  }
}
