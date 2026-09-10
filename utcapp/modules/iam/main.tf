# 1. AssumeRole Policy allowing EC2 service to assume this role
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# 2. EC2 IAM Role
resource "aws_iam_role" "app_role" {
  name_prefix        = "${var.environment}-ec2-app-role-"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name        = "${var.environment}-ec2-app-role"
    Environment = var.environment
  }
}

# 3. Attach AWS Managed Policy for Systems Manager (SSM Session Manager Access)
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 4. Custom Least-Privilege Policy for Application Resources (S3, EFS, Secrets, CloudWatch)
data "aws_iam_policy_document" "app_permissions" {
  # Least-privilege S3 Bucket Access (App Bucket only)
  statement {
    sid    = "S3AppBucketAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
      "s3:DeleteObject"
    ]
    resources = [
      var.s3_bucket_arn,
      "${var.s3_bucket_arn}/*"
    ]
  }

  # Least-privilege Secrets Manager Access (DB Credentials Secret only)
  statement {
    sid    = "SecretsManagerDBAccess"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [
      var.db_secret_arn
    ]
  }

  # Least-privilege EFS Access
  statement {
    sid    = "EFSMountAccess"
    effect = "Allow"
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
      "elasticfilesystem:ClientRootAccess"
    ]
    resources = [
      var.efs_arn
    ]
  }

  # CloudWatch Logs & Metrics Access
  statement {
    sid    = "CloudWatchLogging"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
      "cloudwatch:PutMetricData"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "app_policy" {
  name_prefix = "${var.environment}-ec2-app-policy-"
  description = "Least privilege policy for EC2 application instances"
  policy      = data.aws_iam_policy_document.app_permissions.json
}

resource "aws_iam_role_policy_attachment" "app_policy_attach" {
  role       = aws_iam_role.app_role.name
  policy_arn = aws_iam_policy.app_policy.arn
}

# 5. IAM Instance Profile (Attached to EC2 Launch Template)
resource "aws_iam_instance_profile" "app_profile" {
  name_prefix = "${var.environment}-ec2-instance-profile-"
  role        = aws_iam_role.app_role.name

  tags = {
    Name        = "${var.environment}-ec2-instance-profile"
    Environment = var.environment
  }
}
resource "aws_iam_role_policy" "read_db_secret" {
  name = "${var.environment}-read-db-secret"
  role = aws_iam_role.app_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = var.db_secret_arn
    }]
  })
}