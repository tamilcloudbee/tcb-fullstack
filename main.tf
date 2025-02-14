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

module "vpc_a" {
  source          = "./modules/vpc"
  vpc_cidr        = var.vpc_cidr
  public_cidr_1   = var.public_cidr_1
  private_cidr_1  = var.private_cidr_1
  public_cidr_2   = var.public_cidr_2
  private_cidr_2  = var.private_cidr_2

  env_name        = "dev_a"
  resource_prefix = var.resource_prefix

}

module "nat_gateway" {
  source                 = "./modules/nat_gateway"
  public_subnet_id       = module.vpc_a.public_subnet_1_id
  private_route_table_id = module.vpc_a.private_routetable_id
  resource_prefix        = var.resource_prefix
  env_name               = "dev_a"
}
