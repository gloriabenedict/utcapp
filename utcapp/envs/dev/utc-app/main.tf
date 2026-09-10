module "network" {
  source               = "../../../modules/network"
  vpc_cidr             = "10.0.0.0/16"
  az_count             = 2
  public_subnet_count  = 2
  private_subnet_count = 4
  environment          = "dev"
}

module "security_groups" {
  source      = "../../../modules/security"
  vpc_id      = module.network.vpc_id
  environment = "dev"
  app_port    = 8080 # Port where your application runs on EC2
  db_port     = 5432 # PostgreSQL port (change to 3306 for MySQL/Aurora)
}


module "alb" {
  source                = "../../../modules/alb"
  domain_name           = "linkwithme.info" # Replace with your Route 53 domain name
  subdomain             = "utcapp"          # Will create app.example.com
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  alb_security_group_id = module.security_groups.alb_security_group_id
  app_port              = 8080
  environment           = "dev"
}


module "cloudfront" {
  source       = "../../../modules/cloudfront"
  domain_name  = "linkwithme.info"
  subdomain    = "utcapp"
  alb_dns_name = module.alb.alb_dns_name
  environment  = "dev"

  # Pass the explicit us-east-1 provider alias to the module
  providers = {
    aws.us_east_1 = aws.us_east_1
  }
}
module "Asg" {
  source                    = "../../../modules/Asg"
  environment               = "dev"
  instance_type             = "t3.micro"
  app_security_group_id     = module.security_groups.app_security_group_id
  private_subnet_ids        = module.network.app_subnet_ids
  target_group_arn          = module.alb.target_group_arn
  efs_dns_name              = module.storage.efs_dns_name # Passes the EFS DNS name directly
  iam_instance_profile_name = module.iam.instance_profile_name
  db_secret_arn             = module.database.db_secret_arn
  min_size                  = 2
  max_size                  = 4
  desired_capacity          = 2

}


module "database" {
  source               = "../../../modules/database"
  environment          = "dev"
  db_engine            = "postgres"
  db_engine_version    = "16"
  db_instance_class    = "db.t4g.micro"
  db_security_group_id = module.security_groups.db_security_group_id
  # Pass database subnets (e.g., indices 2 and 3 from private subnets)
  private_subnet_ids      = module.network.db_subnet_ids
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:30-Mon:05:30"
  multi_az                = false # Set to true for production high availability
}

module "storage" {
  source                = "../../../modules/storage"
  environment           = "dev"
  vpc_id                = module.network.vpc_id
  app_security_group_id = module.security_groups.app_security_group_id

  # Deploy EFS Mount Targets into the App Tier Subnets (Subnets 1a, 1b, 1c)
  private_app_subnet_ids = module.network.app_subnet_ids
}

module "iam" {
  source        = "../../../modules/iam"
  environment   = "dev"
  s3_bucket_arn = module.storage.s3_bucket_arn
  efs_arn       = module.storage.efs_arn
  db_secret_arn = module.database.db_secret_arn
}

module "monitoring" {
  source                  = "../../../modules/monitoring"
  environment             = "dev"
  alert_email             = "gloriabenedict@yahoo.com" # Replace with your email address for alerts
  asg_name                = module.Asg.autoscaling_group_name
  alb_arn_suffix          = module.alb.alb_arn_suffix
  target_group_arn_suffix = module.alb.target_group_arn_suffix
  db_instance_id          = module.database.db_instance_id
}
