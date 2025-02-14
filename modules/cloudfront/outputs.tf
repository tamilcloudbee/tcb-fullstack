
output "cloudfront_id" {
  value = aws_cloudfront_distribution.cdn.id
}

output "cloudfront_domain" {
  value = aws_cloudfront_distribution.cdn.domain_name
}

output "cloudfront_hosted_zone_id" {
  value = aws_cloudfront_distribution.cdn.hosted_zone_id
}