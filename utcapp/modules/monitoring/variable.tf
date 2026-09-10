variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
  default     = "dev"
}

variable "alert_email" {
  description = "Email address to receive SNS notifications"
  type        = string
}

variable "asg_name" {
  description = "Name of the EC2 Auto Scaling Group"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the Application Load Balancer for CloudWatch metrics"
  type        = string
}

variable "target_group_arn_suffix" {
  description = "ARN suffix of the ALB Target Group for CloudWatch metrics"
  type        = string
}

variable "db_instance_id" {
  description = "Identifier of the RDS instance"
  type        = string
}