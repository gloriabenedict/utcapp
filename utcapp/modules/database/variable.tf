variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "dev"
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for DB Subnet Group (minimum 2 in different AZs)"
  type        = list(string)
}

variable "db_security_group_id" {
  description = "Security group ID for RDS instance (allows ingress from app tier only)"
  type        = string
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Upper limit for storage autoscaling in GB"
  type        = number
  default     = 100
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_engine" {
  description = "Database engine (e.g. postgres, mysql)"
  type        = string
  default     = "postgres"
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "16"
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master database username"
  type        = string
  default     = "dbadmin"
}

variable "backup_retention_period" {
  description = "Days to retain automated backups (1-35)"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Daily preferred backup window (UTC)"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Weekly preferred maintenance window (UTC)"
  type        = string
  default     = "Mon:04:30-Mon:05:30"
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment for high availability"
  type        = bool
  default     = false
}