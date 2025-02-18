
output "mysql_db_password_parameter_name" {
  value = aws_ssm_parameter.mysql_db_password.name
}

output "mysql_db_name_parameter_name" {
  value = aws_ssm_parameter.mysql_db_name.name
}

output "mysql_db_user_parameter_name" {
  value = aws_ssm_parameter.mysql_db_user.name
}
