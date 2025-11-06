locals {
  aws_region = "us-east-1"
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "aws-ai-devbox-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
  
  default_tags {
    tags = {
      ManagedBy   = "Terragrunt"
      Environment = "${path_relative_to_include()}"
    }
  }
}
EOF
}
