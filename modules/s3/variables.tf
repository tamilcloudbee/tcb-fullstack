variable "bucket_name" {
  type = string
}

variable "enable_oai" {
  type    = bool
  default = true
}

variable "upload_lambda_zip" {
  description = "Whether to upload the lambda zip to this S3 bucket"
  type        = bool
  default     = false
}

variable "lambda_zip_path" {
  description = "Path to the Lambda function ZIP file"
  type        = string
  default     = "lambda_function.zip"
}
