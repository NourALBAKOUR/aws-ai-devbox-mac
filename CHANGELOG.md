# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2024-11-06

### Added
- Initial repository structure and setup
- Bootstrap script for macOS with Homebrew installations
- Python Poetry environment configuration with boto3, sagemaker, and jupyter
- VS Code settings and recommended extensions
- DevContainer configuration for consistent development
- Terraform modules for AWS Bedrock and SageMaker
- Terragrunt live configurations for dev and prod environments
- Docker ECR workflow scripts for building and pushing images
- AWS Bedrock examples:
  - Basic text generation with Claude and Titan
  - Streaming responses
  - RAG (Retrieval-Augmented Generation) implementation
- SageMaker examples:
  - Model training with scikit-learn
  - Custom container training
  - Model deployment and inference
  - Batch transform jobs
- Jupyter notebook examples for Bedrock and SageMaker
- Pre-commit hooks configuration for code quality
- GitHub Actions workflow for linting and Terraform validation
- Comprehensive README with usage examples
- Contributing guidelines
- Makefile for common development tasks
- Environment variable template (.env.example)

### Infrastructure
- S3 buckets for artifacts (Bedrock and SageMaker)
- IAM roles and policies for Bedrock and SageMaker
- ECR repositories for custom containers
- CloudWatch log groups for monitoring
- SageMaker notebook instance configuration

### CI/CD
- GitHub Actions for Python linting (Black, Ruff, MyPy)
- Terraform validation and formatting checks
- Docker build testing
- Pre-commit hook validation

## [Unreleased]

### Planned
- Add unit tests for example code
- Add integration tests
- Add CloudFormation templates as alternative to Terraform
- Add CDK examples for infrastructure
- Add more Bedrock model examples (Stability AI, Cohere)
- Add SageMaker pipeline examples
- Add monitoring and observability dashboards
- Add cost optimization examples
