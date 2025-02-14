provider "aws" {
  region = var.aws_region
}

# Fetch the hosted zone ID dynamically
data "aws_route53_zone" "selected" {
  name         = var.domain
  private_zone = false
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
}

module "acm" {
  source   = "./modules/acm"
  domain   = var.domain
  zone_id  = data.aws_route53_zone.selected.zone_id  # Use dynamic zone_id
}

module "cloudfront" {
  source         = "./modules/cloudfront"
  domain         = var.domain
  bucket_name    = module.s3.bucket_name
  bucket_arn     = module.s3.bucket_arn
  acm_cert_arn   = module.acm.cert_arn
  domain_aliases = [var.domain, join(".", ["www", var.domain])]

  # Pass the new required variables
  bucket_regional_domain_name = module.s3.bucket_regional_domain_name
  oai_iam_arn                 = module.s3.oai_iam_arn
  oai_id                      = module.s3.oai_id
}

module "route53" {
  source                    = "./modules/route53"
  zone_id                   = data.aws_route53_zone.selected.zone_id  # Use dynamic zone_id
  domain                    = var.domain
  cloudfront_domain         = module.cloudfront.cloudfront_domain
  cloudfront_hosted_zone_id = module.cloudfront.cloudfront_hosted_zone_id
}

