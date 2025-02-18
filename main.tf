provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      CreatedBy = "Terraform"
      Project     = "tcb-fullstack"
      Owner       = "tamilcloudbee"
    }
  }
}

/*
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
  
    # Conditionally pass OAI values
  oai_iam_arn   = var.enable_oai ? module.s3.oai_iam_arn : null
  oai_id        = var.enable_oai ? module.s3.oai_id : null
}

module "route53" {
  source                    = "./modules/route53"
  zone_id                   = data.aws_route53_zone.selected.zone_id  # Use dynamic zone_id
  domain                    = var.domain
  cloudfront_domain         = module.cloudfront.cloudfront_domain
  cloudfront_hosted_zone_id = module.cloudfront.cloudfront_hosted_zone_id
}

*/

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
  iam_instance_profile = module.lambda_iam_role.ec2_instance_profile  # Pass IAM profile
  resource_prefix     = var.resource_prefix
}



module "rds" {
  source               = "./modules/rds"
  private_subnet_id_1  = module.vpc_a.private_subnet_1_id  # Use the same subnet as EC2
  private_subnet_id_2  = module.vpc_a.private_subnet_2_id  # Secondary subnet for high availability
  rds_security_group_id = module.sg_a.rds_mysqldb_security_group_id
  db_name              = var.db_name
  db_admin_user        = var.db_admin_user
  db_admin_password    = var.db_admin_password
  resource_prefix      = var.resource_prefix
}



module "ssm_parameter" {
  source          = "./modules/ssm_parameter"
  db_password     = var.db_admin_password
  resource_prefix = var.resource_prefix

  # Add new parameters for RDS database name and username
  db_name         = var.db_name
  db_admin_user   = var.db_admin_user
  rds_endpoint    = module.rds.rds_db_endpoint

}

module "lambda_iam_role" {
  source          = "./modules/iam"  # Path to the IAM module
  resource_prefix = var.resource_prefix 
  role_name       = "${var.resource_prefix}-lambda-role"
  policy_name     = "${var.resource_prefix}-lambda-policy"
  policy_document = jsonencode({
    Version = "2012-10-17"  # IAM policy version date
    Statement = [
      {
        Action = [
          "ssm:GetParameter",  # Permission to get parameters from AWS SSM Parameter Store
          "logs:CreateLogGroup",  # Permission to create a CloudWatch log group
          "logs:CreateLogStream",  # Permission to create a CloudWatch log stream
          "logs:PutLogEvents",  # Permission to send log events to CloudWatch
          "rds:DescribeDBInstances",  # Permission to describe RDS DB instances
          "rds:Connect"  # Permission to connect to RDS (MySQL)
        ]
        Effect   = "Allow"
        Resource = "*"  # Applies to all resources
      },
      {
        Action = [
          "rds:DescribeDBInstances",  # This allows you to describe your DB instances
          "rds:Connect"  # Connect permission for RDS MySQL
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

module "s3_tcb_rds_init" {
  source      = "./modules/s3"
  bucket_name = "tcb-rds-init-s3"
  enable_oai  = false  # Disable OAI for this bucket
}


module "upload_zip_to_s3_bucket" {
  source            = "./modules/s3"
  bucket_name       = module.s3_tcb_rds_init.bucket_name
  upload_lambda_zip = true  # Enable only for the last bucket
  lambda_zip_path   = "lambda_function.zip"
}
