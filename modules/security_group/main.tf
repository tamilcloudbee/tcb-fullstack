
resource "aws_security_group" "ec2_sg" {
  name        = "${var.resource_prefix}-ec2-sg"
  description = "Allow inbound traffic from ALB to EC2 instances"
  vpc_id      = var.vpc_id

  # Existing rule: Allow HTTP traffic from ALB (port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]  # Allow traffic from ALB's SG
  }

  # New rule: Allow traffic on port 8000 from ALB
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]  # Allow traffic from ALB's SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.resource_prefix}-ec2-sg"
  }
}


resource "aws_security_group" "alb_sg" {
  name        = "${var.resource_prefix}-alb-sg"
  description = "Allow traffic from ALB to EC2 instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all incoming HTTP traffic
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.resource_prefix}-alb-sg"
  }
}

 
resource "aws_security_group" "rds_mysqldb_sg" {
  name        = "${var.resource_prefix}-rds-sg"
  description = "Allow traffic from EC2 instance to RDS"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]  # Allow traffic from EC2's SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.resource_prefix}-rds-mysqldb-sg"
  }
}
