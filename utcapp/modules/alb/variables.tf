variable "domain_name" {
  description = "Domain name managed in Route 53 (e.g., example.com)"
  type        = string
}

variable "subdomain" {
  description = "Subdomain prefix for the record (e.g., app or www). Leave empty for apex domain."
  type        = string
  default     = "app"
}

variable "vpc_id" {
  description = "VPC ID where the target group will be registered"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs where the ALB will be deployed"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security Group ID for the ALB"
  type        = string
}

variable "app_port" {
  description = "Port on which the EC2 app instances listen"
  type        = number
  default     = 8080
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "dev"
}