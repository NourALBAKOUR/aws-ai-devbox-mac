include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/sagemaker"
}

inputs = {
  project_name           = "aws-ai-devbox"
  environment            = "dev"
  instance_type          = "ml.t3.medium"
  notebook_instance_type = "ml.t3.medium"
  
  tags = {
    Project     = "AWS AI DevBox"
    Environment = "dev"
    ManagedBy   = "Terragrunt"
  }
}
