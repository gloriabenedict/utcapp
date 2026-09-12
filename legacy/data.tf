data "aws_route53_zone" "selected" {
  name         = "linkwithme.info"
  private_zone = false
}

# Lookup the existing Route53 hosted zone for your domain
data "aws_route53_zone" "primary" {
  name         = "linkwithme.info"
  private_zone = false
}

# Lookup the existing wildcard ACM certificate in us-east-1
data "aws_acm_certificate" "wildcard" {
  domain      = "*.linkwithme.info"
  statuses    = ["ISSUED"]
  most_recent = true
}
# Generate an IAM policy document granting S3 access to CloudFront OAC
data "aws_iam_policy_document" "s3_oac_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.frontend_bucket.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.frontend_cdn.arn]
    }
  }
}
data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}