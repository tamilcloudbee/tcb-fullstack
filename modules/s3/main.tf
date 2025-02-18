resource "aws_s3_bucket" "static_site" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.static_site.id

  # Block all public access
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  count   = var.enable_oai ? 1 : 0
  comment = "CloudFront OAI for ${var.bucket_name}"
}

resource "aws_s3_bucket_policy" "allow_cloudfront" {
  count   = var.enable_oai ? 1 : 0
  bucket = aws_s3_bucket.static_site.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.oai.iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.static_site.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_website_configuration" "static_site" {
  count   = var.enable_oai ? 1 : 0
  bucket = aws_s3_bucket.static_site.id
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_object" "lambda_zip" {
  count  = var.upload_lambda_zip ? 1 : 0  # Only execute for the last S3 bucket
  bucket = aws_s3_bucket.static_site.id
  key    = "lambda_function.zip"
  source = var.lambda_zip_path
  acl    = "private"

  etag = filemd5(var.lambda_zip_path) # Ensures re-upload only if file changes
}
