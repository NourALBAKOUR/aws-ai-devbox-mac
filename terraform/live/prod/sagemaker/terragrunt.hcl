include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/sagemaker"
}

inputs = {
  project_name           = "aws-ai-devbox"
  environment            = "prod"
  instance_type          = "ml.m5.xlarge"
  notebook_instance_type = "ml.t3.large"
  
  tags = {
    Project     = "AWS AI DevBox"
    Environment = "prod"
    ManagedBy   = "Terragrunt"
  }
}
