# Vpc
module "vpc" {
  source         = "../../modules/vpc"
  vpc_cidr_block = "192.168.0.0/16"
  vpc_name       = "Dev-vpc"
}

#front end
module "frontend" {
  source                 = "../../modules/frontendaws"
  bucket_name            = "frontend.linkwithme.info"
  aws_origin_access_name = "cross access from cloudfront"
  cert_domain            = "*.linkwithme.info"
  dns_record             = "frontend.linkwithme.info"
  hosted_zone_name       = "linkwithme.info"
}