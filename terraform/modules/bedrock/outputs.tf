output "execution_role_arn" {
  description = "ARN of the Bedrock execution role"
  value       = aws_iam_role.bedrock_execution_role.arn
}

output "artifacts_bucket_name" {
  description = "Name of the S3 bucket for Bedrock artifacts"
  value       = aws_s3_bucket.bedrock_artifacts.id
}

output "artifacts_bucket_arn" {
  description = "ARN of the S3 bucket for Bedrock artifacts"
  value       = aws_s3_bucket.bedrock_artifacts.arn
}

output "log_group_name" {
  description = "Name of the CloudWatch log group for Bedrock"
  value       = aws_cloudwatch_log_group.bedrock_logs.name
}
