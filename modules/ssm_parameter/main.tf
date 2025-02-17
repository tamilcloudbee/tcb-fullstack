resource "aws_ssm_parameter" "mysql_db_password" {
  name        = "${var.resource_prefix}-mysql-db-password"
  description = "MySQL DB password"
  type        = "SecureString"
  value       = var.db_password

  tags = {
    Name = "${var.resource_prefix}-mysql-db-password"
  }
}
