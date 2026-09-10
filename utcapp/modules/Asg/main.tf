# 1. Fetch the latest official Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# 2. Launch Template
resource "aws_launch_template" "app" {
  name_prefix   = "${var.environment}-app-lt-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type

  vpc_security_group_ids = [var.app_security_group_id]
  # Attach IAM Instance Profile
  iam_instance_profile {
    name = var.iam_instance_profile_name
  }
  # ... remainder of launch template config ...

  # Enforce IMDSv2 for security best practices
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  # Root disk volume configuration
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  # Example Bootstrap User Data script
user_data = base64encode(<<-EOF
  #!/bin/bash
  set -euxo pipefail

  yum update -y
  yum install -y amazon-efs-utils python3 jq

  # --- EFS mount, with retry ---
  mkdir -p /mnt/efs
  echo "${var.efs_dns_name}:/ /mnt/efs efs _netdev,tls 0 0" >> /etc/fstab

  for i in 1 2 3 4 5; do
    mount -a -t efs && break
    sleep 15
  done

  # --- App content (local, not EFS) ---
  mkdir -p /var/www
  TOKEN=$$(curl -sX PUT http://169.254.169.254/latest/api/token \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
  IID=$$(curl -s -H "X-aws-ec2-metadata-token: $${TOKEN}" \
    http://169.254.169.254/latest/meta-data/instance-id)
  echo "Hello from 3-Tier App Server $${IID}" > /var/www/index.html

  # --- Run under systemd so it restarts and survives reboot ---
  cat > /etc/systemd/system/app.service <<'UNIT'
  [Unit]
  After=network-online.target remote-fs.target

  [Service]
  Environment=DB_SECRET_ARN=${var.db_secret_arn}
  WorkingDirectory=/var/www
  ExecStart=/usr/bin/python3 -m http.server 8080
  Restart=always

  [Install]
  WantedBy=multi-user.target
  UNIT

  systemctl daemon-reload
  systemctl enable --now app.service
EOF
)
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.environment}-app-instance"
      Environment = var.environment
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# 3. Auto Scaling Group
resource "aws_autoscaling_group" "app" {
  name_prefix         = "${var.environment}-app-asg-"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [var.target_group_arn]

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  # Health Check setup relying on ALB health checks
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  # Zero-downtime rolling update configuration when Launch Template updates
  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
    }

    triggers = ["tag"]
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity] # Allows external autoscaling policies to manage scale
  }
}

# 4. Target Tracking Auto Scaling Policy (CPU-based scaling)
resource "aws_autoscaling_policy" "cpu_high" {
  name                   = "${var.environment}-cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 60.0
  }
}

