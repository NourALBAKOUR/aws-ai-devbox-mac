# SageMaker Terraform Module

This module provisions AWS resources for Amazon SageMaker development.

## Resources Created

- IAM execution role for SageMaker
- IAM policies for SageMaker and S3 access
- S3 bucket for SageMaker data (with versioning and encryption)
- SageMaker notebook instance
- ECR repository for custom containers
- CloudWatch log group for SageMaker logs

## Usage

```hcl
module "sagemaker" {
  source = "./modules/sagemaker"
  
  project_name           = "my-project"
  environment            = "dev"
  instance_type          = "ml.t3.medium"
  notebook_instance_type = "ml.t3.medium"
  
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
| instance_type | SageMaker instance type | `string` | `"ml.t3.medium"` | no |
| notebook_instance_type | SageMaker notebook instance type | `string` | `"ml.t3.medium"` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| execution_role_arn | ARN of the SageMaker execution role |
| bucket_name | Name of the S3 bucket for SageMaker |
| bucket_arn | ARN of the S3 bucket for SageMaker |
| notebook_instance_name | Name of the SageMaker notebook instance |
| ecr_repository_url | URL of the ECR repository for SageMaker containers |
| log_group_name | Name of the CloudWatch log group for SageMaker |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Notes

- The SageMaker notebook instance is created but not started by default
- The ECR repository has image scanning enabled on push
- S3 bucket has public access blocked and encryption enabled
