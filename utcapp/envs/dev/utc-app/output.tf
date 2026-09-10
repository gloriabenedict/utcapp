output "application_url" {
  description = "Fully Qualified Domain Name pointing to CloudFront CDN"
  value       = module.cloudfront.cloudfront_domain_name
}
output "alb_dns_name" {
  description = "DNS endpoint of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront Distribution ID for cache invalidation"
  value       = module.cloudfront.cloudfront_distribution_id
}

output "db_endpoint" {
  description = "Database connection endpoint (hostname:port)"
  value       = module.database.db_instance_endpoint
}

output "db_secret_arn" {
  description = "ARN of Secrets Manager secret containing database master credentials"
  value       = module.database.db_secret_arn
}

output "efs_dns_name" {
  description = "DNS name of the EFS file system shared mount"
  value       = module.storage.efs_dns_name
}

output "s3_backup_bucket" {
  description = "S3 bucket name for backups and logs"
  value       = module.storage.s3_bucket_name
}

output "sns_alert_topic_arn" {
  description = "ARN of the SNS alert topic"
  value       = module.monitoring.sns_topic_arn
}