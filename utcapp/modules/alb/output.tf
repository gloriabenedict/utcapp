output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "target_group_arn" {
  description = "ARN of the target group to attach EC2 instances or Auto Scaling Groups"
  value       = aws_lb_target_group.app.arn
}

output "app_fqdn" {
  description = "Fully qualified domain name pointing to the ALB"
  value       = aws_route53_record.alb_alias.fqdn
}

output "alb_arn_suffix" {
  value = aws_lb.main.arn_suffix
}

output "target_group_arn_suffix" {
  value = aws_lb_target_group.app.arn_suffix
}