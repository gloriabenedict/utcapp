# ==========================================
# 1. SNS TOPIC & EMAIL SUBSCRIPTION
# ==========================================

resource "aws_sns_topic" "alerts" {
  name = "${var.environment}-utc-auto-scaling-alerts"

  tags = {
    Name        = "${var.environment}-alerts-topic"
    Environment = var.environment
  }
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# ==========================================
# 2. CLOUDWATCH LOG GROUP (App Logs)
# ==========================================

resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/aws/ec2/${var.environment}-app-logs"
  retention_in_days = 30

  tags = {
    Name        = "${var.environment}-app-logs"
    Environment = var.environment
  }
}

# ==========================================
# 3. CLOUDWATCH ALARMS
# ==========================================

# Alarm 1: ASG High CPU Utilization (> 80%)
resource "aws_cloudwatch_metric_alarm" "asg_high_cpu" {
  alarm_name          = "${var.environment}-asg-high-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Triggered when average CPU utilization across ASG exceeds 80%"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }
}

# Alarm 2: ALB 5xx Server Errors
resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "${var.environment}-alb-high-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "Triggered when target 5xx error count exceeds 10 in 1 minute"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    TargetGroup  = var.target_group_arn_suffix
    LoadBalancer = var.alb_arn_suffix
  }
}

# Alarm 3: RDS Low Free Storage Space (< 5 GB)
resource "aws_cloudwatch_metric_alarm" "rds_low_storage" {
  alarm_name          = "${var.environment}-rds-low-free-storage"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 5368709120 # 5 GB in bytes
  alarm_description   = "Triggered when free database storage drops below 5 GB"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id
  }
}

# Alarm 4: Unhealthy Host Count on Target Group
resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  alarm_name          = "${var.environment}-alb-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "Triggered when one or more EC2 instances fail target group health checks"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    TargetGroup  = var.target_group_arn_suffix
    LoadBalancer = var.alb_arn_suffix
  }
}