variable "bucket_name" {
  description = "Bucket Name"
}

variable "aws_origin_access_name" {
  
}
variable "CloudFront_default_object" {
  default = "index.html"
}

variable "CloudFront_origin_id" {
  default = "S3-terraform.linkwithme.info"
}
variable "cert_domain" {
    
}
variable "dns_record" {
  
}

variable "hosted_zone_name" {
  
}