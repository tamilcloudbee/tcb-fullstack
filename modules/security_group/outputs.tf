

output "alb_security_group_id" {
  value = aws_security_group.alb_sg.id
}


output "ec2_security_group_id" {
  value = aws_security_group.ec2_sg.id
}

output "rds_mysqldb_security_group_id" {
  value = aws_security_group.rds_mysqldb_sg.id
}


