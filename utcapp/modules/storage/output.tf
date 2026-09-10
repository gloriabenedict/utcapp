# S3 Outputs
output "s3_bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.app_bucket.id
}

output "s3_bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.app_bucket.arn
}

# EFS Outputs
output "efs_id" {
  description = "ID of the EFS File System"
  value       = aws_efs_file_system.shared_fs.id
}

output "efs_dns_name" {
  description = "DNS name of the EFS File System for mounting"
  value       = aws_efs_file_system.shared_fs.dns_name
}

output "efs_security_group_id" {
  description = "Security Group ID attached to EFS Mount Targets"
  value       = aws_security_group.efs.id
}

output "efs_arn" {
  value = aws_efs_file_system.shared_fs.arn
}