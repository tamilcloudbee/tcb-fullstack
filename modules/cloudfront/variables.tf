variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket to be used as the CloudFront origin"
}

variable "bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket"
}

variable "acm_cert_arn" {
  type        = string
  description = "ARN of the ACM certificate for HTTPS"
}

variable "domain" {
  type        = string
  description = "Primary domain for CloudFront"
}

variable "domain_aliases" {
  type        = list(string)
  description = "List of additional domain aliases for CloudFront"
  default     = []
}

variable "bucket_regional_domain_name" {
  type        = string
  description = "The regional domain name of the S3 bucket"
}

variable "oai_iam_arn" {
  type        = string
  description = "The IAM ARN of the CloudFront Origin Access Identity (OAI)"

}

variable "oai_id" {
  type        = string
  description = "The ID of the CloudFront Origin Access Identity (OAI)"
}