provider "aws" {
  region = var.aws_region
}

/*
provider "github" {
  token = var.github_token  # Required if the repository is private
}
*/

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  handler       = var.handler
  runtime       = var.runtime
  role          = var.role_arn

  environment {
    variables = var.environment_variables
  }

  # Using the zip file directly from GitHub
  source_code_hash = var.source_code_hash

  # Lambda function code directly from GitHub
  zip_file = var.zip_file
}

