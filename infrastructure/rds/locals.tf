locals {
  publicly_accessible = var.disable_rds_public_access ? false : true
  tags = merge({
    Name    = var.db_identifier
    OwnedBy = "Terraform"
  }, var.tags)
  security_group_map = { for key in var.allowed_cidrs : key.name => key }
  lambda_layer       = var.engine == "mysql" ? "pymysql.zip" : "psycopg2.zip"
}
