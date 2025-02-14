output "s3_bucket_name" {
  value = module.s3.bucket_name
}

output "cloudfront_distribution_id" {
  value = module.cloudfront.cloudfront_id
}

output "cloudfront_domain" {
  value = module.cloudfront.cloudfront_domain
}

output "route53_record_fqdn" {
  value = module.route53.cloudfront_root_record
}
