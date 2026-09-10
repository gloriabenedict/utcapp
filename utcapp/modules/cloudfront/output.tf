output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.main.id
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "cdn_fqdn" {
  description = "Fully Qualified Domain Name pointing to CloudFront"
  value       = aws_route53_record.cdn_alias.fqdn
}