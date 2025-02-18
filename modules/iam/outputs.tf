output "tcb_role_arn" {
  value = aws_iam_role.iam-tcb.arn
}

output "ec2_instance_profile" {
  value = aws_iam_instance_profile.ec2_instance_profile.name
}
