resource "aws_ssm_parameter" "mysql_db_password" {
  name        = "${var.resource_prefix}-mysql-db-password"
  description = "MySQL DB password"
  type        = "SecureString"
  value       = var.db_password
  overwrite   = true  # Allow overwriting the parameter if it already exists

  tags = {
    Name = "${var.resource_prefix}-mysql-db-password"
  }
}
