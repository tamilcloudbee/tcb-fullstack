variable "create_nat_gateway" {
  description = "Flag to create NAT Gateway"
  type        = bool
  default     = true
}

variable "public_subnet_id" {
  description = "The ID of the public subnet where the NAT Gateway will be deployed"
  type        = string
}

variable "private_routetable_id" {
  description = "The ID of the private route table to associate with the NAT Gateway"
  type        = string
}

variable "resource_prefix" {
  description = "Prefix for all resources"
  type        = string
}

variable "env_name" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}
