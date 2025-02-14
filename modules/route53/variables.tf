variable "zone_id" {
  type        = string
  description = "The Route 53 hosted zone ID"
}

variable "domain" {
  type        = string
  description = "The root domain name (e.g., tamilcloudbee.com)"
}

variable "cloudfront_domain" {
  type        = string
  description = "CloudFront distribution domain name"
}

variable "cloudfront_hosted_zone_id" {
  type        = string
  description = "CloudFront hosted zone ID for alias records"
}
