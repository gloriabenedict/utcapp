# Terraform configuration requiring us-east-1 provider for CloudFront ACM certificate
terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.us_east_1]
    }
  }
}

# 1. Look up existing Hosted Zone in Route 53
data "aws_route53_zone" "selected" {
  name         = var.domain_name
  private_zone = false
}

# 2. Look up existing ISSUED ACM Certificate in us-east-1 (Required by CloudFront)
data "aws_acm_certificate" "us_east_1_cert" {
  provider = aws.us_east_1
  domain   = "*.${var.domain_name}"
  statuses = ["ISSUED"]

  most_recent = true
}

locals {
  fqdn      = var.subdomain != "" ? "${var.subdomain}.${var.domain_name}" : var.domain_name
  origin_id = "ALB-${var.environment}-origin"
}

# 3. CloudFront Distribution
resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CDN distribution for ${local.fqdn}"
  aliases             = [local.fqdn]
  price_class         = "PriceClass_100" # Uses US, Canada, Europe edge locations (Cost-effective)

  origin {
    domain_name = var.alb_dns_name
    origin_id   = local.origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.origin_id

    # Forward all headers, cookies, and query strings to ALB (Optimized for dynamic app servers)
    forwarded_values {
      query_string = true

      headers = ["*"]

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0      # Default to 0 for dynamic web applications; tune based on static caching needs
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.us_east_1_cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name        = "${var.environment}-cdn"
    Environment = var.environment
  }
}

# 4. Route 53 Record pointing domain/subdomain to CloudFront Distribution
resource "aws_route53_record" "cdn_alias" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = local.fqdn
  type    = "A"
  allow_overwrite = true

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = false
  }
}