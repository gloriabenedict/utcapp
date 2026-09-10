variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "VPC ID where the EFS Security Group will reside"
  type        = string
}

variable "app_security_group_id" {
  description = "Security Group ID of the EC2 app servers to allow inbound access to EFS"
  type        = string
}

variable "private_app_subnet_ids" {
  description = "List of private App subnet IDs where EFS Mount Targets will be deployed"
  type        = list(string)
}