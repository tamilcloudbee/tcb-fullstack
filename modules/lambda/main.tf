resource "aws_lambda_function" "this" {
  function_name = var.function_name
  handler       = var.handler
  runtime       = var.runtime
  role          = var.role_arn

  environment {
    variables = var.environment_variables
  }

  source_code_hash = filebase64sha256("${path.module}/lambda_function.zip")

  s3_bucket = aws_s3_bucket.lambda_bucket.bucket
  s3_key    = "lambda_function.zip"
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.function_name}-lambda-bucket"
}

resource "aws_s3_bucket_object" "lambda_code" {
  bucket = aws_s3_bucket.lambda_bucket.bucket
  key    = "lambda_function.zip"
  source = "${path.module}/lambda_function.zip"
  etag   = filemd5("${path.module}/lambda_function.zip")
}
