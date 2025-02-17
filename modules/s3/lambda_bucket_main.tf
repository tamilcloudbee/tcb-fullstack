resource "aws_s3_bucket" "lambda_zip_bucket" {
  bucket = var.lambda_zip_bucket_name
  acl    = "private"  # Set this to private if you want to keep it secure
}

resource "aws_s3_bucket_public_access_block" "block_public_lambda_zip" {
  bucket = aws_s3_bucket.lambda_zip_bucket.id

  # Block all public access
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
