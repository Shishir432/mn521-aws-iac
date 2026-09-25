provider "aws" {
  region = var.aws_region

  # Every resource created by this project receives these tags, which makes
  # ownership, cost tracking and clean-up easy in the AWS console.
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Unit        = "MN521"
    }
  }
}
