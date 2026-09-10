# 1. Public Load Balancer Security Group
resource "aws_security_group" "alb" {
  name        = "${var.environment}-alb-sg"
  description = "Controls HTTP/HTTPS inbound traffic to the Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    ="-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-alb-sg"
    Environment = var.environment
  }
}

# 2. Private App Server Security Group
resource "aws_security_group" "app" {
  name        = "${var.environment}-app-sg"
  description = "Controls access to EC2 app instances, allowing traffic ONLY from ALB"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow traffic from ALB on application port"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all outbound traffic (for OS updates, external APIs via NAT GW)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-app-sg"
    Environment = var.environment
  }
}

# 3. Private Database Security Group
resource "aws_security_group" "db" {
  name        = "${var.environment}-db-sg"
  description = "Controls access to RDS, allowing traffic ONLY from App Servers"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow database connections from App Servers"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    description = "Allow no outbound traffic from DB layer by default"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-db-sg"
    Environment = var.environment
  }
}