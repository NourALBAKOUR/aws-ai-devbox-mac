terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# IAM role for SageMaker
resource "aws_iam_role" "sagemaker_execution_role" {
  name = "${var.project_name}-${var.environment}-sagemaker-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-sagemaker-execution-role"
      Environment = var.environment
    }
  )
}

# Attach AWS managed policy for SageMaker full access
resource "aws_iam_role_policy_attachment" "sagemaker_full_access" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

# Additional policy for S3 access
resource "aws_iam_role_policy" "sagemaker_s3_policy" {
  name = "${var.project_name}-${var.environment}-sagemaker-s3-policy"
  role = aws_iam_role.sagemaker_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.sagemaker_bucket.arn,
          "${aws_s3_bucket.sagemaker_bucket.arn}/*"
        ]
      }
    ]
  })
}

# S3 bucket for SageMaker
resource "aws_s3_bucket" "sagemaker_bucket" {
  bucket = "${var.project_name}-${var.environment}-sagemaker-data"

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-sagemaker-data"
      Environment = var.environment
    }
  )
}

resource "aws_s3_bucket_versioning" "sagemaker_bucket" {
  bucket = aws_s3_bucket.sagemaker_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sagemaker_bucket" {
  bucket = aws_s3_bucket.sagemaker_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "sagemaker_bucket" {
  bucket = aws_s3_bucket.sagemaker_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# SageMaker Notebook Instance
resource "aws_sagemaker_notebook_instance" "notebook" {
  name          = "${var.project_name}-${var.environment}-notebook"
  role_arn      = aws_iam_role.sagemaker_execution_role.arn
  instance_type = var.notebook_instance_type

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-notebook"
      Environment = var.environment
    }
  )
}

# ECR repository for SageMaker custom containers
resource "aws_ecr_repository" "sagemaker_repo" {
  name                 = "${var.project_name}-${var.environment}-sagemaker"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-sagemaker-repo"
      Environment = var.environment
    }
  )
}

# CloudWatch Log Group for SageMaker
resource "aws_cloudwatch_log_group" "sagemaker_logs" {
  name              = "/aws/sagemaker/${var.project_name}-${var.environment}"
  retention_in_days = 7

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-sagemaker-logs"
      Environment = var.environment
    }
  )
}
