output "db_instance_endpoint" {
  description = "Connection endpoint for the RDS instance"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_address" {
  description = "Hostname address of the RDS instance"
  value       = aws_db_instance.main.address
}

output "db_instance_port" {
  description = "Port on which the database listens"
  value       = aws_db_instance.main.port
}

output "db_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret storing DB credentials"
  value       = aws_db_instance.main.master_user_secret[0].secret_arn
}
output "db_instance_id" {
  value = aws_db_instance.main.id      # match your actual resource name
}
