include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../modules/bedrock"
}

inputs = {
  project_name = "aws-ai-devbox"
  environment  = "dev"
  bedrock_model_id = "anthropic.claude-3-sonnet-20240229-v1:0"
  
  tags = {
    Project     = "AWS AI DevBox"
    Environment = "dev"
    ManagedBy   = "Terragrunt"
  }
}
