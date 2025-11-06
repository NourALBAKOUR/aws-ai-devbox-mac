# Bedrock Terraform Module

This module provisions AWS resources for Amazon Bedrock development.

## Resources Created

- IAM execution role for Bedrock
- IAM policy for Bedrock model invocation
- S3 bucket for Bedrock artifacts (with versioning and encryption)
- CloudWatch log group for Bedrock logs

## Usage

```hcl
module "bedrock" {
  source = "./modules/bedrock"
  
  project_name     = "my-project"
  environment      = "dev"
  bedrock_model_id = "anthropic.claude-3-sonnet-20240229-v1:0"
  
  tags = {
    Project     = "My Project"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Name of the project | `string` | n/a | yes |
| environment | Environment name (dev, prod, etc.) | `string` | n/a | yes |
| bedrock_model_id | Bedrock model ID to use | `string` | `"anthropic.claude-3-sonnet-20240229-v1:0"` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| execution_role_arn | ARN of the Bedrock execution role |
| artifacts_bucket_name | Name of the S3 bucket for Bedrock artifacts |
| artifacts_bucket_arn | ARN of the S3 bucket for Bedrock artifacts |
| log_group_name | Name of the CloudWatch log group for Bedrock |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |
