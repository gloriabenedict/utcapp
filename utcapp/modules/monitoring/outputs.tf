output "sns_topic_arn" {
  description = "ARN of the SNS alert topic"
  value       = aws_sns_topic.alerts.arn
}

output "log_group_name" {
  description = "Name of the CloudWatch Log Group for application logs"
  value       = aws_cloudwatch_log_group.app_logs.name
}