variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "policy_name" {
  description = "Name of the IAM policy"
  type        = string
}

variable "policy_document" {
  description = "Policy document for the IAM role"
  type        = string
}
