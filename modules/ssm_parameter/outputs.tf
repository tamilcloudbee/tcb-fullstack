output "mysql_db_password_parameter_name" {
  value = aws_ssm_parameter.mysql_db_password.name
}
