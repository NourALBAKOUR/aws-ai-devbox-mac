output "execution_role_arn" {
  description = "ARN of the SageMaker execution role"
  value       = aws_iam_role.sagemaker_execution_role.arn
}

output "bucket_name" {
  description = "Name of the S3 bucket for SageMaker"
  value       = aws_s3_bucket.sagemaker_bucket.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket for SageMaker"
  value       = aws_s3_bucket.sagemaker_bucket.arn
}

output "notebook_instance_name" {
  description = "Name of the SageMaker notebook instance"
  value       = aws_sagemaker_notebook_instance.notebook.name
}

output "ecr_repository_url" {
  description = "URL of the ECR repository for SageMaker containers"
  value       = aws_ecr_repository.sagemaker_repo.repository_url
}

output "log_group_name" {
  description = "Name of the CloudWatch log group for SageMaker"
  value       = aws_cloudwatch_log_group.sagemaker_logs.name
}
