variable "resource_prefix" {
  description = "Prefix for the resources"
  type        = string
}

variable "db_password" {
  description = "The MySQL database password"
  type        = string
}

variable "db_name" {
  description = "The MySQL database name"
  type        = string
}

variable "db_admin_user" {
  description = "The MySQL database admin username"
  type        = string
}

variable "rds_endpoint" {
  description = "The MySQL database RDS endpoint"
  type        = string
}
