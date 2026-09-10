variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "dev"
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 storage bucket"
  type        = string
}

variable "efs_arn" {
  description = "ARN of the EFS File System"
  type        = string
}

variable "db_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret storing DB credentials"
  type        = string
}