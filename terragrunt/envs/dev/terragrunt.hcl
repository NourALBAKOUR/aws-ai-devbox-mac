# Development Environment Configuration

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../infra/modules"
}

inputs = {
  project_name = "ml-platform-dev"
  environment  = "dev"
  
  # VPC Configuration
  vpc_cidr             = "10.0.0.0/16"
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]
  
  # ECR Configuration
  ecr_repositories = ["sagemaker-inference", "sagemaker-training"]
  
  # Tags
  additional_tags = {
    CostCenter = "development"
    Owner      = "ml-team"
  }
}
