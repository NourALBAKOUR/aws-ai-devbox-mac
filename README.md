# AWS AI DevBox Mac

🚀 **One-command Mac bootstrap for professional AWS development focused on Bedrock and SageMaker**

This repository provides a comprehensive setup for macOS to quickly get started with AWS AI/ML development, specifically targeting Amazon Bedrock and Amazon SageMaker. It includes Homebrew installation scripts, VS Code configuration, devcontainer setup, Terraform modules, Terragrunt live configs, Docker ECR workflows, and a complete Python Poetry environment with pre-configured examples.

## 🎯 Features

- **One-Command Bootstrap**: Automated setup script for macOS
- **Development Tools**: AWS CLI, CDK, Terraform, Terragrunt, Docker
- **Python Environment**: Poetry-managed environment with boto3, sagemaker, jupyter
- **VS Code Integration**: Pre-configured settings and recommended extensions
- **DevContainer Support**: Consistent development environment across machines
- **Infrastructure as Code**: Terraform modules and Terragrunt live configs
- **Docker ECR Workflow**: Scripts for building and pushing to AWS ECR
- **Example Code**: Working examples for Bedrock and SageMaker
- **Pre-commit Hooks**: Code quality and validation before commits
- **CI/CD**: GitHub Actions for linting and Terraform validation

## 📋 Prerequisites

- macOS (10.15 or later)
- Administrator access to install software
- AWS Account with appropriate permissions
- At least 10GB of free disk space

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/NourALBAKOUR/aws-ai-devbox-mac.git
cd aws-ai-devbox-mac
```

### 2. Run Bootstrap Script

```bash
chmod +x scripts/bootstrap.sh
./scripts/bootstrap.sh
```

This will install:
- Homebrew
- Git, curl, wget, jq, tree
- AWS CLI
- AWS CDK
- Terraform and Terragrunt
- Docker Desktop
- Python 3.11
- Poetry
- VS Code and extensions
- Pre-commit hooks

### 3. Configure AWS Credentials

```bash
aws configure
```

Enter your AWS Access Key ID, Secret Access Key, region, and output format.

### 4. Set Up Python Environment

```bash
# Create .env file from template
cp .env.example .env
# Edit .env with your AWS account details

# Install Python dependencies
poetry install

# Activate the environment
poetry shell
```

### 5. Initialize Pre-commit Hooks

```bash
pre-commit install
```

## 📁 Repository Structure

```
aws-ai-devbox-mac/
├── .devcontainer/          # DevContainer configuration
│   └── devcontainer.json
├── .github/
│   └── workflows/          # GitHub Actions workflows
│       └── lint-validate.yml
├── .vscode/                # VS Code settings
│   ├── settings.json
│   └── extensions.json
├── examples/               # Example code
│   ├── bedrock/           # Bedrock examples
│   │   ├── bedrock_examples.py
│   │   ├── bedrock_rag.py
│   │   └── bedrock_quickstart.ipynb
│   └── sagemaker/         # SageMaker examples
│       ├── training.py
│       ├── inference.py
│       └── sagemaker_quickstart.ipynb
├── scripts/               # Utility scripts
│   ├── bootstrap.sh      # Main setup script
│   └── ecr-push.sh       # Docker ECR push workflow
├── terraform/
│   ├── modules/          # Terraform modules
│   │   ├── bedrock/     # Bedrock infrastructure
│   │   └── sagemaker/   # SageMaker infrastructure
│   └── live/            # Terragrunt live configs
│       ├── terragrunt.hcl
│       ├── dev/
│       │   ├── bedrock/
│       │   └── sagemaker/
│       └── prod/
│           ├── bedrock/
│           └── sagemaker/
├── .env.example           # Environment variables template
├── .gitignore
├── .pre-commit-config.yaml
├── Dockerfile
├── pyproject.toml        # Poetry configuration
├── README.md
└── LICENSE
```

## 🔧 Usage

### AWS Bedrock Examples

#### Basic Text Generation

```python
from examples.bedrock.bedrock_examples import BedrockClient

# Initialize client
client = BedrockClient(region_name="us-east-1")

# Generate text with Claude
response = client.invoke_claude("Explain AWS Bedrock in simple terms.")
print(response)
```

#### Streaming Responses

```python
# Generate streaming response
for chunk in client.invoke_model_with_streaming("Write a haiku about AI."):
    print(chunk, end="", flush=True)
```

#### RAG (Retrieval-Augmented Generation)

```python
from examples.bedrock.bedrock_rag import BedrockRAG

rag_client = BedrockRAG()
context_docs = ["AWS Bedrock is a fully managed service..."]
response = rag_client.query_with_context("What is Bedrock?", context_docs)
```

### SageMaker Examples

#### Training a Model

```python
from examples.sagemaker.training import SageMakerTrainer

# Initialize trainer
trainer = SageMakerTrainer(role_arn="your-sagemaker-role-arn")

# Prepare and upload data
train_path, test_path = trainer.prepare_sample_data()
train_s3_uri = trainer.upload_data_to_s3(train_path, "train")

# Train model (requires training script)
estimator = trainer.train_sklearn_model(train_s3_uri, "train.py")
```

#### Running Inference

```python
from examples.sagemaker.inference import SageMakerInference
import numpy as np

# Initialize inference client
inference = SageMakerInference(role_arn="your-sagemaker-role-arn")

# Invoke endpoint
data = np.array([[1.0, 2.0, 3.0, 4.0, 5.0]])
result = inference.invoke_endpoint("my-endpoint", data)
print(result)
```

### Jupyter Notebooks

Start Jupyter Lab:

```bash
poetry run jupyter lab
```

Open the example notebooks:
- `examples/bedrock/bedrock_quickstart.ipynb`
- `examples/sagemaker/sagemaker_quickstart.ipynb`

## 🏗️ Infrastructure Setup with Terraform

### Initialize Terraform Modules

```bash
# Bedrock module
cd terraform/modules/bedrock
terraform init
terraform plan
terraform apply

# SageMaker module
cd ../sagemaker
terraform init
terraform plan
terraform apply
```

### Using Terragrunt for Live Configs

```bash
# Deploy development environment
cd terraform/live/dev/bedrock
terragrunt plan
terragrunt apply

cd ../sagemaker
terragrunt plan
terragrunt apply

# Deploy production environment
cd ../../prod/bedrock
terragrunt plan
terragrunt apply
```

## 🐳 Docker Workflow

### Build and Push to ECR

```bash
# Set environment variables
export AWS_ACCOUNT_ID=your-account-id
export AWS_REGION=us-east-1
export IMAGE_NAME=aws-ai-devbox
export IMAGE_TAG=latest

# Run the ECR push script
./scripts/ecr-push.sh
```

### Run Docker Container Locally

```bash
docker build -t aws-ai-devbox:latest .
docker run -p 8888:8888 -v ~/.aws:/root/.aws aws-ai-devbox:latest
```

## 🔍 Pre-commit Hooks

The repository includes pre-commit hooks for:
- Trailing whitespace removal
- End-of-file fixing
- YAML/JSON validation
- Python formatting (Black)
- Python linting (Ruff)
- Type checking (MyPy)
- Terraform formatting and validation

Run manually:
```bash
pre-commit run --all-files
```

## 🚦 CI/CD with GitHub Actions

The repository includes a GitHub Actions workflow that runs on every push and pull request:

- **Python Linting**: Black, Ruff, MyPy
- **Terraform Validation**: Format check, init, and validate
- **Pre-commit Checks**: All pre-commit hooks
- **Docker Build**: Test Docker image build

## 📚 Documentation

### Key Technologies

- **AWS Bedrock**: Foundation models for text, image, and code generation
- **Amazon SageMaker**: Machine learning model training and deployment
- **Terraform**: Infrastructure as Code
- **Terragrunt**: Terraform wrapper for DRY configurations
- **Poetry**: Python dependency management
- **Docker**: Containerization
- **Pre-commit**: Git hooks for code quality

### Additional Resources

- [AWS Bedrock Documentation](https://docs.aws.amazon.com/bedrock/)
- [Amazon SageMaker Documentation](https://docs.aws.amazon.com/sagemaker/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Poetry Documentation](https://python-poetry.org/docs/)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- AWS for providing excellent AI/ML services
- The open-source community for amazing tools and libraries

## 📧 Contact

For questions or support, please open an issue on GitHub.

---

**Happy coding! 🎉**
