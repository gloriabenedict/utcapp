provider "aws" {
  region = "us-east-1" # Your primary region (e.g., us-east-1, us-west-2, etc.)
}

# Explicit provider alias for us-east-1 (Required for CloudFront ACM lookup)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}