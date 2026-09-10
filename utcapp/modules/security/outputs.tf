output "alb_security_group_id" {
  description = "Security Group ID for the ALB"
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "Security Group ID for the EC2 App instances"
  value       = aws_security_group.app.id
}

output "db_security_group_id" {
  description = "Security Group ID for the RDS Database instance"
  value       = aws_security_group.db.id
}