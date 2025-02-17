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
  private_routetable_id = module.vpc_a.private_routetable_id
  resource_prefix        = var.resource_prefix
  env_name               = "dev_a"
}

module "sg_a" {
  source   = "./modules/security_group"
  vpc_id   = module.vpc_a.vpc_id
  env_name = "dev_a"
  resource_prefix = var.resource_prefix
}

module "ec2_a" {
  source              = "./modules/ec2"
  instance_type       = "t2.micro"
  private_subnet_id   = module.vpc_a.private_subnet_1_id
  user_data           = file("userdata-fastapi.sh")
  key_name            = var.key_name
  env_name            = "dev_a"
  security_group_id   = module.sg_a.ec2_security_group_id
  resource_prefix     = var.resource_prefix
}


module "rds" {
  source               = "./modules/rds"
  private_subnet_id_1  = module.vpc_a.private_subnet_1_id
  rds_security_group_id = module.sg_a.rds_mysqldb_security_group_id
  db_name              = var.db_name
  db_admin_user        = var.db_admin_user
  db_admin_password    = var.db_admin_password
  resource_prefix      = var.resource_prefix
}

module "ssm_parameter" {
  source        = "./modules/ssm_parameter"
  db_password   = var.db_admin_password
  resource_prefix = var.resource_prefix
}

module "lambda_iam_role" {
  source = "./modules/iam"

  role_name    = "${var.resource_prefix}-lambda-role"
  policy_name  = "${var.resource_prefix}-lambda-policy"
  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:GetParameter",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Fetch the Lambda function ZIP file from the GitHub release
data "http" "lambda_function_zip" {
  url = "https://github.com/tamilcloudbee/tcb-mysql-rds-init/releases/tag/v1.0.0/lambda_function.zip"  # Replace with your actual GitHub release URL
}

module "lambda_function" {
  source = "./modules/lambda"

  function_name = "${var.resource_prefix}-rds-init"
  runtime       = "python3.12"
  handler       = "lambda_function.lambda_handler"
  source_repo   = "https://github.com/tamilcloudbee/tcb-mysql-rds-init.git"
  role_arn      =  module.lambda_iam_role.tcb_role_arn

  environment_variables = {
    DB_HOST           = module.rds.rds_db_endpoint
    DB_NAME           = var.db_name
    DB_USER           = var.db_admin_user
    DB_PASSWORD_PARAM = module.ssm_parameter.mysql_db_password_parameter_name
  }
  # Pass the zip file and source code hash
  zip_file         = data.http.lambda_function_zip.body
  source_code_hash = base64sha256(data.http.lambda_function_zip.body)
}
