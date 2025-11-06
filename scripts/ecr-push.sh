#!/usr/bin/env bash
#
# Docker ECR workflow script
# Build, tag, and push Docker images to AWS ECR
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}➜ $1${NC}"
}

# Check required environment variables
if [ -z "${AWS_ACCOUNT_ID:-}" ]; then
    print_error "AWS_ACCOUNT_ID environment variable is not set"
    exit 1
fi

if [ -z "${AWS_REGION:-}" ]; then
    print_error "AWS_REGION environment variable is not set"
    exit 1
fi

# Default values
IMAGE_NAME="${IMAGE_NAME:-aws-ai-devbox}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
ECR_REPO="${ECR_REPO:-${IMAGE_NAME}}"

# ECR repository URL
ECR_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
FULL_IMAGE_NAME="${ECR_URL}/${ECR_REPO}:${IMAGE_TAG}"

print_info "Building Docker image..."
docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" .
print_success "Docker image built: ${IMAGE_NAME}:${IMAGE_TAG}"

print_info "Logging in to AWS ECR..."
aws ecr get-login-password --region "${AWS_REGION}" | \
    docker login --username AWS --password-stdin "${ECR_URL}"
print_success "Logged in to ECR"

print_info "Creating ECR repository if it doesn't exist..."
aws ecr describe-repositories --repository-names "${ECR_REPO}" --region "${AWS_REGION}" 2>/dev/null || \
    aws ecr create-repository --repository-name "${ECR_REPO}" --region "${AWS_REGION}" \
        --image-scanning-configuration scanOnPush=true \
        --encryption-configuration encryptionType=AES256
print_success "ECR repository ready: ${ECR_REPO}"

print_info "Tagging image for ECR..."
docker tag "${IMAGE_NAME}:${IMAGE_TAG}" "${FULL_IMAGE_NAME}"
print_success "Image tagged: ${FULL_IMAGE_NAME}"

print_info "Pushing image to ECR..."
docker push "${FULL_IMAGE_NAME}"
print_success "Image pushed to ECR: ${FULL_IMAGE_NAME}"

echo ""
print_success "🎉 Docker image successfully pushed to ECR!"
echo ""
echo "Image URL: ${FULL_IMAGE_NAME}"
echo ""
