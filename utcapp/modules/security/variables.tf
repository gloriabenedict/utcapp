variable "vpc_id" {
  description = "The ID of the VPC where security groups will be created"
  type        = string
}

variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
  default     = "dev"
}

variable "app_port" {
  description = "Port on which the application server listens (e.g., 80, 8080, 3000)"
  type        = number
  default     = 80
}

variable "db_port" {
  description = "Port on which the database engine listens (e.g., 3306 for MySQL, 5432 for Postgres)"
  type        = number
  default     = 5432
}