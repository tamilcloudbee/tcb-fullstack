output "cloudfront_root_record" {
  value = aws_route53_record.cloudfront_root.fqdn
}

output "cloudfront_www_record" {
  value = aws_route53_record.cloudfront_www.fqdn
}
