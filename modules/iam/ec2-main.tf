resource "aws_iam_role" "ec2_role" {
  name = "${var.resource_prefix}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "ec2_rds_ssm_policy" {
  name   = "${var.resource_prefix}-ec2-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["rds:DescribeDBInstances", "rds:Connect"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParametersByPath"]
        Resource = "arn:aws:ssm:*:*:parameter/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_rds_ssm_attach" {
  policy_arn = aws_iam_policy.ec2_rds_ssm_policy.arn
  role       = aws_iam_role.ec2_role.name
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.resource_prefix}-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}
