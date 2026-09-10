# ==========================================
# 1. AMAZON S3 BUCKET (Logs / Backups)
# ==========================================

# Unique random suffix for S3 bucket naming
resource "random_string" "s3_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "aws_s3_bucket" "app_bucket" {
  bucket        = "utc-app-storage-${var.environment}-${random_string.s3_suffix.result}"
  force_destroy = var.environment == "dev" ? true : false

  tags = {
    Name        = "${var.environment}-s3-storage"
    Environment = var.environment
  }
}

# Block all public access (Security Best Practice)
resource "aws_s3_bucket_public_access_block" "app_bucket_privacy" {
  bucket = aws_s3_bucket.app_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable Server-Side Encryption (AES256)
resource "aws_s3_bucket_server_side_encryption_configuration" "app_bucket_encryption" {
  bucket = aws_s3_bucket.app_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enable Versioning for Backups/Logs safety
resource "aws_s3_bucket_versioning" "app_bucket_versioning" {
  bucket = aws_s3_bucket.app_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}


# ==========================================
# 2. AMAZON EFS (Shared File System)
# ==========================================

# Dedicated Security Group for EFS
resource "aws_security_group" "efs" {
  name        = "${var.environment}-efs-sg"
  description = "Allows NFS inbound traffic ONLY from EC2 App Servers"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow NFS port 2049 from App Servers"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-efs-sg"
    Environment = var.environment
  }
}

# Elastic File System Creation
resource "aws_efs_file_system" "shared_fs" {
  creation_token   = "${var.environment}-efs-shared"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true

  # Lifecycle policy to transition cold files to Infrequent Access (IA) to cut costs
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name        = "${var.environment}-efs-shared"
    Environment = var.environment
  }
}

# EFS Mount Targets (One in each Private App Subnet across AZs)
resource "aws_efs_mount_target" "app_mount_target" {
  count           = length(var.private_app_subnet_ids)
  file_system_id  = aws_efs_file_system.shared_fs.id
  subnet_id       = var.private_app_subnet_ids[count.index]
  security_groups = [aws_security_group.efs.id]
}