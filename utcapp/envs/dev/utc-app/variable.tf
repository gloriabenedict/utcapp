variable "environment" {
  description = "Environment name for resource naming and tagging (e.g. dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "Primary AWS region for infrastructure deployment"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the Virtual Private Cloud"
  type        = string
  default     = "10.10.0.0/16"
}

variable "az_count" {
  description = "Number of Availability Zones to span across"
  type        = number
  default     = 3
}

variable "domain_name" {
  description = "Route 53 domain name (e.g., example.com)"
  type        = string
}

variable "subdomain" {
  description = "Subdomain prefix for application record (e.g., app)"
  type        = string
  default     = "app"
}

variable "app_port" {
  description = "Port listener for application web server on EC2 instances"
  type        = number
  default     = 8080
}

variable "db_engine" {
  description = "RDS engine (mysql or postgres)"
  type        = string
  default     = "mysql"
}

variable "db_instance_class" {
  description = "RDS database instance tier"
  type        = string
  default     = "db.t4g.micro"
}

variable "alert_email" {
  description = "Email address to receive CloudWatch SNS alarm alerts"
  type        = string
}
