
resource "aws_ssm_parameter" "mysql_db_password" {
  name        = "${var.resource_prefix}-mysql-db-password"
  description = "MySQL DB password"
  type        = "SecureString"
  value       = var.db_password

  tags = {
    Name = "${var.resource_prefix}-mysql-db-password"
  }
}

resource "aws_ssm_parameter" "mysql_db_name" {
  name        = "${var.resource_prefix}-mysql-db-name"
  description = "MySQL DB name"
  type        = "SecureString"
  value       = var.db_name

  tags = {
    Name = "${var.resource_prefix}-mysql-db-name"
  }
}

resource "aws_ssm_parameter" "mysql_db_user" {
  name        = "${var.resource_prefix}-mysql-db-user"
  description = "MySQL DB admin username"
  type        = "SecureString"
  value       = var.db_admin_user

  tags = {
    Name = "${var.resource_prefix}-mysql-db-user"
  }
}

resource "aws_ssm_parameter" "rds_endpoint" {
  name  = "${var.resource_prefix}-rds-endpoint"
  type  = "SecureString"
  value = var.rds_endpoint

  tags = {
    Name        = "${var.resource_prefix}-rds-endpoint"
    Environment = var.resource_prefix
  }
}
