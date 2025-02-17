resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.resource_prefix}-rds-subnet-group"
  subnet_ids = [var.private_subnet_id_1,var.private_subnet_id_2]  # Using private subnet 1

  tags = {
    Name = "${var.resource_prefix}-rds-subnet-group"
  }
}

resource "aws_db_instance" "rds-db" {
  db_name              = var.db_name
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  storage_type         = "gp2"
  allocated_storage    = 20
  vpc_security_group_ids = [var.rds_security_group_id]
  username             = var.db_admin_user
  password             = var.db_admin_password
  publicly_accessible   = false 
  skip_final_snapshot  = true
  multi_az               = false
  tags = {
    Name = "${var.resource_prefix}-rds"
  }


}
