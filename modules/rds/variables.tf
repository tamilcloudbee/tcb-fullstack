variable "db_name" {
  description = "RDS DB name"
  type        = string
  
}

variable "db_admin_user" {
  description = "RDS DB Admin Username"
  type        = string

}

variable "db_admin_password" {
  description = "RDS DB admin password"
  type        = string

}

variable "private_subnet_id_1" {
  description = "ID of the private subnet where the RDS instance will be deployed"
  type        = string
}

variable "rds_security_group_id" {
  description = "ID of the RDS security group"
  type        = string
}

variable "resource_prefix" {
  description = "Prefix for the resources"
  type        = string
}
