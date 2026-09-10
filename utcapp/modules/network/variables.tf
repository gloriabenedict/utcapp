variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of Availability Zones to deploy across"
  type        = number
  default     = 2
}

variable "public_subnet_count" {
  description = "Number of public subnets (typically 1 per AZ)"
  type        = number
  default     = 2
}

variable "private_subnet_count" {
  description = "Number of private subnets (e.g., App layer + DB layer)"
  type        = number
  default     = 4
}

variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
  default     = "dev"
}