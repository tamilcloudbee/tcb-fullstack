


output "bucket_name" {
  value = aws_s3_bucket.static_site.id
}

output "bucket_arn" {
  value = aws_s3_bucket.static_site.arn
}

output "bucket_regional_domain_name" {
  value = aws_s3_bucket.static_site.bucket_regional_domain_name
}

/*
output "oai_iam_arn" {
  value = aws_cloudfront_origin_access_identity.oai.iam_arn
}


output "oai_id" {
  value = aws_cloudfront_origin_access_identity.oai.id
}

*/
