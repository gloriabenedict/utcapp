variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type for application servers"
  type        = string
  default     = "t3.micro"
}

variable "app_security_group_id" {
  description = "Security group ID for app servers (restricts ingress to ALB only)"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs where instances will launch"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ARN of the ALB target group to attach instances"
  type        = string
}

variable "min_size" {
  description = "Minimum number of instances in the ASG"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of instances in the ASG"
  type        = number
  default     = 4
}

variable "desired_capacity" {
  description = "Desired number of instances in the ASG"
  type        = number
  default     = 2
}

variable "efs_dns_name" {
  description = "DNS name of the EFS File System"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "Name of the IAM Instance Profile for EC2 instances"
  type        = string
}
variable "db_secret_arn" {
  type = string
}