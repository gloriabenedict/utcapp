output "instance_profile_name" {
  description = "Name of the IAM Instance Profile to attach to Launch Template"
  value       = aws_iam_instance_profile.app_profile.name
}

output "instance_profile_arn" {
  description = "ARN of the IAM Instance Profile"
  value       = aws_iam_instance_profile.app_profile.arn
}

output "role_arn" {
  description = "ARN of the EC2 IAM Role"
  value       = aws_iam_role.app_role.arn
}