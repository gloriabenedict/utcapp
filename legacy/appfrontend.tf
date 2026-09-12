
# Create a private S3 bucket to store the static frontend assets
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "terraform.linkwithme.info"
}

# Block all public network access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "frontend_bucket_block" {
  bucket = aws_s3_bucket.frontend_bucket.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# Create a CloudFront Origin Access Control (OAC) to secure the S3 origin
resource "aws_cloudfront_origin_access_control" "frontend_oac" {
  name                              = "terraform-mydomain-com-oac"
  description                       = "OAC for terraform.mydomain.com S3 bucket access"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"

}

# Deploy the CloudFront CDN distribution
resource "aws_cloudfront_distribution" "frontend_cdn" {
  enabled             = true
  default_root_object = "index.html"
  aliases             = ["terraform.linkwithme.info"]

  # Define the backend origin server configuration (S3)
  origin {
    origin_id                = "S3-terraform.linkwithme.info"
    domain_name              = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend_oac.id

  }

  # Configure default request routing and caching behavior

  default_cache_behavior {
    target_origin_id       = "S3-terraform.linkwithme.info"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id = data.aws_cloudfront_cache_policy.caching_optimized.id

  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.wildcard.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

# Attach the generated IAM policy document directly to the S3 bucket
resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id
  policy = data.aws_iam_policy_document.s3_oac_policy.json
}

resource "aws_route53_record" "frontend_dns" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "terraform.mydomain.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.frontend_cdn.domain_name
    zone_id                = aws_cloudfront_distribution.frontend_cdn.hosted_zone_id
    evaluate_target_health = false

  }

}