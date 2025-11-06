.PHONY: help install setup test lint format clean docker-build docker-push tf-init tf-validate

help:
	@echo "AWS AI DevBox Mac - Available Commands"
	@echo "======================================"
	@echo "setup          - Run initial setup (bootstrap)"
	@echo "install        - Install Python dependencies"
	@echo "test           - Run tests"
	@echo "lint           - Run linters (black, ruff, mypy)"
	@echo "format         - Format code with black"
	@echo "clean          - Clean generated files"
	@echo "docker-build   - Build Docker image"
	@echo "docker-push    - Build and push to ECR"
	@echo "tf-init        - Initialize Terraform modules"
	@echo "tf-validate    - Validate Terraform configuration"
	@echo "jupyter        - Start Jupyter Lab"
	@echo "pre-commit     - Run pre-commit hooks"

setup:
	@echo "Running bootstrap script..."
	./scripts/bootstrap.sh

install:
	@echo "Installing Python dependencies..."
	poetry install

test:
	@echo "Running tests..."
	poetry run pytest tests/ -v --cov=examples

lint:
	@echo "Running linters..."
	poetry run black --check .
	poetry run ruff check .
	poetry run mypy examples/ --ignore-missing-imports

format:
	@echo "Formatting code..."
	poetry run black .
	poetry run ruff check --fix .

clean:
	@echo "Cleaning generated files..."
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type d -name ".pytest_cache" -exec rm -rf {} +
	find . -type d -name ".mypy_cache" -exec rm -rf {} +
	find . -type d -name ".ruff_cache" -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	find . -type d -name "*.egg-info" -exec rm -rf {} +

docker-build:
	@echo "Building Docker image..."
	docker build -t aws-ai-devbox:latest .

docker-push:
	@echo "Building and pushing to ECR..."
	@if [ -z "$(AWS_ACCOUNT_ID)" ]; then \
		echo "Error: AWS_ACCOUNT_ID not set"; \
		exit 1; \
	fi
	@if [ -z "$(AWS_REGION)" ]; then \
		echo "Error: AWS_REGION not set"; \
		exit 1; \
	fi
	./scripts/ecr-push.sh

tf-init:
	@echo "Initializing Terraform modules..."
	cd terraform/modules/bedrock && terraform init
	cd terraform/modules/sagemaker && terraform init

tf-validate:
	@echo "Validating Terraform configuration..."
	terraform fmt -check -recursive terraform/
	cd terraform/modules/bedrock && terraform init -backend=false && terraform validate
	cd terraform/modules/sagemaker && terraform init -backend=false && terraform validate

jupyter:
	@echo "Starting Jupyter Lab..."
	poetry run jupyter lab

pre-commit:
	@echo "Running pre-commit hooks..."
	pre-commit run --all-files

dev:
	@echo "Setting up development environment..."
	poetry install
	pre-commit install
	@echo "Development environment ready!"
