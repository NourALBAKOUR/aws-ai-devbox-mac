# Terragrunt Root Configuration
# This file is used by all child configurations

locals {
  # Load environment-specific variables
  environment = basename(get_terragrunt_dir())
  region      = "us-east-1"
  
  # Common tags
  common_tags = {
    Environment = local.environment
    ManagedBy   = "Terragrunt"
    Project     = "aws-mac-bootstrap"
  }
}

# Configure Terragrunt to use S3 backend
remote_state {
  backend = "s3"
  
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  
  config = {
    bucket         = "terraform-state-${get_aws_account_id()}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.region
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

# Generate provider configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  
  contents = <<EOF
terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "${local.region}"
  
  default_tags {
    tags = {
      Environment = "${local.environment}"
      ManagedBy   = "Terragrunt"
      Project     = "aws-mac-bootstrap"
    }
  }
}
EOF
}

# Input variables passed to all modules
inputs = {
  environment = local.environment
  region      = local.region
  tags        = local.common_tags
}
