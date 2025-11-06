# 03 - Docker for SageMaker Containers

## Overview

Docker is essential for:
- Building custom SageMaker inference containers
- Local testing before deployment
- Reproducible environments

Two options:
- **Docker Desktop** - Full-featured, resource-intensive
- **Colima** - Lightweight, open-source alternative

## Docker Desktop

### Start Docker Desktop

```bash
open -a Docker
```

Or from Applications folder.

### Verify Installation

```bash
docker --version
docker ps
docker run hello-world
```

### Configuration

Docker Desktop → Preferences:
- **Resources:** Allocate 4+ CPUs, 8+ GB RAM
- **File Sharing:** Add project directories
- **Experimental Features:** Enable if needed

### Performance Tips (Apple Silicon)

- Enable "Use Rosetta for x86/amd64 emulation"
- Enable "VirtioFS" for faster file sharing
- Allocate sufficient memory (8GB recommended)

## Colima (Lightweight Alternative)

### Start Colima

```bash
colima start --cpu 4 --memory 8 --disk 100
```

### Verify

```bash
colima status
docker ps
```

### Stop Colima

```bash
colima stop
```

### Restart with Different Resources

```bash
colima delete
colima start --cpu 8 --memory 16 --arch aarch64
```

### Architecture

```bash
# Apple Silicon
colima start --arch aarch64

# Intel/Rosetta
colima start --arch x86_64
```

## Building SageMaker Inference Container

### Structure

```
docker/sagemaker-inference/
├── Dockerfile
├── requirements.txt
└── app.py  # Copied from ai/src/inference/
```

### Build Image

```bash
cd docker/
make build
```

Or manually:
```bash
cd docker/sagemaker-inference/
docker build -t sagemaker-inference:latest .
```

### Test Locally

```bash
cd docker/
make test
```

Or manually:
```bash
docker run --rm -d -p 8080:8080 --name sagemaker-test sagemaker-inference:latest
```

Test health endpoint:
```bash
curl http://localhost:8080/ping
```

Test inference:
```bash
curl -X POST http://localhost:8080/invocations \
  -H "Content-Type: application/json" \
  -d '{"features": [1.0, 2.0, 3.0, 4.0]}'
```

View logs:
```bash
docker logs sagemaker-test
```

Stop container:
```bash
docker stop sagemaker-test
```

## Amazon ECR Integration

### Login to ECR

```bash
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  <account-id>.dkr.ecr.us-east-1.amazonaws.com
```

Or use Make:
```bash
cd docker/
make ecr-login
```

### Create ECR Repository

```bash
aws ecr create-repository \
  --repository-name sagemaker-inference \
  --region us-east-1
```

Or use Make:
```bash
cd docker/
make ecr-create
```

### Tag and Push Image

```bash
cd docker/
make tag
make push
```

Or manually:
```bash
docker tag sagemaker-inference:latest \
  <account-id>.dkr.ecr.us-east-1.amazonaws.com/sagemaker-inference:latest

docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/sagemaker-inference:latest
```

### Full Deploy Workflow

```bash
cd docker/
make deploy  # Builds, tags, and pushes
```

## Dockerfile Best Practices

### Multi-Stage Builds

```dockerfile
# Build stage
FROM python:3.12 AS builder
WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Runtime stage
FROM python:3.12-slim
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY app.py .
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8080"]
```

### Layer Caching

Order instructions from least to most frequently changed:

```dockerfile
# 1. System packages (rarely change)
RUN apt-get update && apt-get install -y gcc

# 2. Python dependencies (change occasionally)
COPY requirements.txt .
RUN pip install -r requirements.txt

# 3. Application code (changes frequently)
COPY app.py .
```

### Security

- Use slim base images: `python:3.12-slim`
- Don't run as root: `USER 1000`
- Scan for vulnerabilities: `docker scan`
- Pin package versions in `requirements.txt`

## SageMaker Container Requirements

SageMaker expects:

### Endpoints

- **`/ping`** - Health check (GET)
- **`/invocations`** - Inference (POST)

### Port

- Listen on port `8080`

### Model Location

- Models stored in `/opt/ml/model/`

### Environment Variables

```python
import os

MODEL_DIR = os.getenv("SM_MODEL_DIR", "/opt/ml/model")
```

## Local Testing Workflow

### 1. Build Image

```bash
cd docker/
make build
```

### 2. Start Container

```bash
make test
```

### 3. Test Endpoints

Health check:
```bash
curl http://localhost:8080/ping
```

Inference:
```bash
curl -X POST http://localhost:8080/invocations \
  -H "Content-Type: application/json" \
  -d '{
    "features": [5.1, 3.5, 1.4, 0.2, 2.3, 1.8, 4.5, 6.2, 1.1, 3.3]
  }'
```

### 4. View Logs

```bash
docker logs -f sagemaker-test
```

### 5. Stop Container

```bash
make stop
```

## Multi-Architecture Builds

For ARM and x86 compatibility:

```bash
docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64 -t myimage:latest .
```

## Docker Compose (Optional)

For multi-container setups, create `docker-compose.yml`:

```yaml
version: '3.8'
services:
  inference:
    build: ./sagemaker-inference
    ports:
      - "8080:8080"
    environment:
      - AWS_REGION=us-east-1
    volumes:
      - ./models:/opt/ml/model
```

Run:
```bash
docker-compose up
```

## Troubleshooting

### Port Already in Use

```bash
# Find process
lsof -i :8080

# Kill process
kill -9 <PID>
```

### Build Cache Issues

```bash
docker build --no-cache -t myimage:latest .
```

### Permission Denied

```bash
# Add user to docker group (Colima)
sudo usermod -aG docker $USER
newgrp docker
```

### M1/M2 Compatibility

Build for x86:
```bash
docker buildx build --platform linux/amd64 -t myimage:latest .
```

### ECR Login Expired

Token expires after 12 hours:
```bash
make ecr-login
```

## Clean Up

### Remove Containers

```bash
docker ps -a  # List all
docker rm $(docker ps -aq)  # Remove all
```

### Remove Images

```bash
docker images
docker rmi <image-id>
docker image prune -a  # Remove unused
```

### Remove Volumes

```bash
docker volume ls
docker volume prune
```

### Complete Clean

```bash
docker system prune -a --volumes
```

## Cost Optimization

### ECR Lifecycle Policies

Keep only N recent images:

```json
{
  "rules": [{
    "rulePriority": 1,
    "description": "Keep last 10 images",
    "selection": {
      "tagStatus": "any",
      "countType": "imageCountMoreThan",
      "countNumber": 10
    },
    "action": {"type": "expire"}
  }]
}
```

Apply:
```bash
aws ecr put-lifecycle-policy \
  --repository-name sagemaker-inference \
  --lifecycle-policy-text file://policy.json
```

---

**Next:** [04 - Terraform & Terragrunt](04-terraform-terragrunt.md)
