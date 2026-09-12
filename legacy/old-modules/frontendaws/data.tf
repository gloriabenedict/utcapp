data "aws_acm_certificate" "wildcard" {
  domain      = var.cert_domain
  statuses    = ["ISSUED"]
  most_recent = true
}
data "aws_route53_zone" "primary" {
  name         = var.hosted_zone_name
  private_zone = false
}

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