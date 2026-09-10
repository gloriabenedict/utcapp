# 1. Random Password Generation (stored securely in AWS Secrets Manager)
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# 2. AWS Secrets Manager Secret & Version for Master Password
resource "aws_secretsmanager_secret" "db_credentials" {
  name_prefix             = "${var.environment}-db-credentials-"
  recovery_window_in_days = 0 # Forces immediate deletion on terraform destroy for easy teardown

  tags = {
    Name        = "${var.environment}-db-credentials"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    engine   = var.db_engine
    host     = aws_db_instance.main.address
    port     = aws_db_instance.main.port
    username = var.db_username
    password = random_password.db_password.result
    dbname   = var.db_name
  })
}

# 3. DB Subnet Group across private subnets
resource "aws_db_subnet_group" "main" {
  name        = "${var.environment}-db-subnet-group"
  subnet_ids  = var.private_subnet_ids
  description = "Subnet group for ${var.environment} database layer"

  tags = {
    Name        = "${var.environment}-db-subnet-group"
    Environment = var.environment
  }
}

# 4. DB Parameter Group (Optional optimization)
resource "aws_db_parameter_group" "main" {
  name        = "${var.environment}-${var.db_engine}-pg"
  family      = "${var.db_engine}16"
  description = "Custom parameter group for ${var.environment} ${var.db_engine}"

  tags = {
    Name        = "${var.environment}-db-parameter-group"
    Environment = var.environment
  }
}

# 5. Primary RDS Instance
resource "aws_db_instance" "main" {
  identifier = "${var.environment}-db"

  # Engine & Compute Configuration
  engine               = var.db_engine
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance_class
  allocated_storage    = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage # Enables automatic storage expansion
  storage_type         = "gp3"

  # Database Credentials & Initial DB
  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result

  # Networking & Security
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_security_group_id]
  publicly_accessible    = false
  multi_az              = var.multi_az

  # Backup & Maintenance Settings
  backup_retention_period   = var.backup_retention_period # Enable automated daily snapshots
  backup_window             = var.backup_window
  maintenance_window        = var.maintenance_window
  copy_tags_to_snapshot     = true
  deletion_protection       = false # Set to true for production

  # Storage Encryption
  storage_encrypted = true

  # Parameter Group
  parameter_group_name = aws_db_parameter_group.main.name

  # Operational Safeguards
  skip_final_snapshot       = true # Set to false and specify final_snapshot_identifier for production
  final_snapshot_identifier = "${var.environment}-db-final-snapshot"

  tags = {
    Name        = "${var.environment}-db"
    Environment = var.environment
  }
}