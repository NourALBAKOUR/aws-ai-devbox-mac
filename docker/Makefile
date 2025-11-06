.PHONY: help build test push deploy clean

# Variables
AWS_REGION ?= us-east-1
AWS_ACCOUNT_ID ?= $(shell aws sts get-caller-identity --query Account --output text)
ECR_REPO_NAME ?= sagemaker-inference
IMAGE_TAG ?= latest
IMAGE_NAME = $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(ECR_REPO_NAME):$(IMAGE_TAG)

help: ## Show this help
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Build Docker image
	@echo "Building Docker image..."
	cd sagemaker-inference && docker build -t $(ECR_REPO_NAME):$(IMAGE_TAG) .
	@echo "✓ Image built: $(ECR_REPO_NAME):$(IMAGE_TAG)"

test: ## Test Docker image locally
	@echo "Starting container on port 8080..."
	docker run --rm -d -p 8080:8080 --name sagemaker-test $(ECR_REPO_NAME):$(IMAGE_TAG)
	@echo "Waiting for container to start..."
	@sleep 3
	@echo "Testing health endpoint..."
	@curl -s http://localhost:8080/ping || true
	@echo ""
	@echo "✓ Container running. Test with: curl http://localhost:8080/docs"
	@echo "Stop with: make clean"

stop: ## Stop test container
	@echo "Stopping test container..."
	@docker stop sagemaker-test || true
	@echo "✓ Container stopped"

ecr-login: ## Login to ECR
	@echo "Logging in to ECR..."
	aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
	@echo "✓ Logged in to ECR"

ecr-create: ## Create ECR repository if it doesn't exist
	@echo "Creating ECR repository..."
	@aws ecr describe-repositories --repository-names $(ECR_REPO_NAME) --region $(AWS_REGION) 2>/dev/null || \
		aws ecr create-repository --repository-name $(ECR_REPO_NAME) --region $(AWS_REGION)
	@echo "✓ ECR repository ready"

tag: ## Tag image for ECR
	@echo "Tagging image for ECR..."
	docker tag $(ECR_REPO_NAME):$(IMAGE_TAG) $(IMAGE_NAME)
	@echo "✓ Image tagged: $(IMAGE_NAME)"

push: ecr-login tag ## Push image to ECR
	@echo "Pushing image to ECR..."
	docker push $(IMAGE_NAME)
	@echo "✓ Image pushed: $(IMAGE_NAME)"

pull: ecr-login ## Pull image from ECR
	@echo "Pulling image from ECR..."
	docker pull $(IMAGE_NAME)
	@echo "✓ Image pulled: $(IMAGE_NAME)"

all: build test ## Build and test locally

deploy: build ecr-create push ## Build, tag, and push to ECR

clean: stop ## Clean up local resources
	@echo "Removing local images..."
	@docker rmi $(ECR_REPO_NAME):$(IMAGE_TAG) || true
	@echo "✓ Cleaned up"

info: ## Show configuration
	@echo "Configuration:"
	@echo "  AWS Region:      $(AWS_REGION)"
	@echo "  AWS Account:     $(AWS_ACCOUNT_ID)"
	@echo "  ECR Repo:        $(ECR_REPO_NAME)"
	@echo "  Image Tag:       $(IMAGE_TAG)"
	@echo "  Full Image Name: $(IMAGE_NAME)"
