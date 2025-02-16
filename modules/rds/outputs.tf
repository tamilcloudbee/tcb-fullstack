output "rds_db_endpoint" {
  value = aws_db_instance.rds_db.endpoint
}

output "rds_db_arn" {
  value = aws_db_instance.rds_db.arn
}
