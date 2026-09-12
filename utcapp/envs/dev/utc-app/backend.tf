terraform {
  backend "s3" {
    bucket       = "terraform-gb-2026"
    key          = "utcapp/dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}