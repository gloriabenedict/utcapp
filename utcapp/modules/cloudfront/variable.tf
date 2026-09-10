variable "domain_name" {
  description = "Domain name managed in Route 53 (e.g., example.com)"
  type        = string
}

variable "subdomain" {
  description = "Subdomain prefix for the record (e.g., app or www). Leave empty for apex domain."
  type        = string
  default     = "app"
}

variable "alb_dns_name" {
  description = "DNS name of the origin ALB"
  type        = string
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "dev"
}