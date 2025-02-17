variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "runtime" {
  description = "Runtime environment for the Lambda function"
  type        = string
  default     = "python3.8"
}

variable "handler" {
  description = "Lambda function entry point"
  type        = string
  default     = "lambda_function.lambda_handler"
}

variable "source_repo" {
  description = "GitHub repository containing the Lambda function code"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
}

variable "role_arn" {
  description = "ARN of the IAM role for the Lambda function"
  type        = string
}


variable "source_code_hash" {
  description = "The base64-encoded SHA256 hash of the Lambda deployment package"
  type        = string
}

variable "zip_file" {
  description = "The Lambda deployment package in zip format"
  type        = string
}
