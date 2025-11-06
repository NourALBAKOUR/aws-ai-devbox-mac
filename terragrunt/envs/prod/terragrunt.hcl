# Production Environment Configuration

include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../infra/modules"
}

inputs = {
  project_name = "ml-platform-prod"
  environment  = "prod"
  
  # VPC Configuration
  vpc_cidr             = "10.1.0.0/16"
  private_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  public_subnet_cidrs  = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
  
  # ECR Configuration
  ecr_repositories = ["sagemaker-inference", "sagemaker-training"]
  
  # Tags
  additional_tags = {
    CostCenter = "production"
    Owner      = "ml-team"
    Backup     = "daily"
  }
}
