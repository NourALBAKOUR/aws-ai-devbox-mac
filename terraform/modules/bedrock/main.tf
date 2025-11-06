terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# IAM role for Bedrock access
resource "aws_iam_role" "bedrock_execution_role" {
  name = "${var.project_name}-${var.environment}-bedrock-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "bedrock.amazonaws.com",
            "sagemaker.amazonaws.com"
          ]
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-bedrock-execution-role"
      Environment = var.environment
    }
  )
}

# IAM policy for Bedrock access
resource "aws_iam_role_policy" "bedrock_policy" {
  name = "${var.project_name}-${var.environment}-bedrock-policy"
  role = aws_iam_role.bedrock_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream",
          "bedrock:ListFoundationModels",
          "bedrock:GetFoundationModel"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# S3 bucket for Bedrock artifacts
resource "aws_s3_bucket" "bedrock_artifacts" {
  bucket = "${var.project_name}-${var.environment}-bedrock-artifacts"

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-bedrock-artifacts"
      Environment = var.environment
    }
  )
}

resource "aws_s3_bucket_versioning" "bedrock_artifacts" {
  bucket = aws_s3_bucket.bedrock_artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bedrock_artifacts" {
  bucket = aws_s3_bucket.bedrock_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "bedrock_artifacts" {
  bucket = aws_s3_bucket.bedrock_artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CloudWatch Log Group for Bedrock
resource "aws_cloudwatch_log_group" "bedrock_logs" {
  name              = "/aws/bedrock/${var.project_name}-${var.environment}"
  retention_in_days = 7

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-bedrock-logs"
      Environment = var.environment
    }
  )
}
