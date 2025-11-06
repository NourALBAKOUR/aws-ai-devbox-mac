# AWS Mac Bootstrap for Bedrock & SageMaker

> **Production-ready MacBook development environment for AWS AI/ML infrastructure with Terraform and Terragrunt**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Terraform](https://img.shields.io/badge/Terraform-1.6+-purple.svg)](https://www.terraform.io/)
[![Python](https://img.shields.io/badge/Python-3.12-blue.svg)](https://www.python.org/)

This repository provides a complete, automated bootstrap for MacBook (Apple Silicon & Intel) to build AWS solutions with:
- **Amazon Bedrock** - Foundation models and generative AI
- **Amazon SageMaker** - ML training, deployment, and endpoints
- **Terraform & Terragrunt** - Infrastructure as code
- **Docker** - Container builds for SageMaker inference
- **VS Code** - Optimized IDE configuration with Copilot

## Quick Start

### Prerequisites
- macOS 12+ (Monterey or later)
- Admin access to install Homebrew
- AWS account with appropriate permissions

### One-Command Bootstrap

```bash
git clone https://github.com/YOUR-USERNAME/aws-mac-bootstrap-bedrock-sagemaker.git
cd aws-mac-bootstrap-bedrock-sagemaker

# Run all bootstrap scripts
bash bootstrap/install_homebrew.sh && \
bash bootstrap/install_cli_mac.sh && \
bash bootstrap/install_langs.sh && \
bash bootstrap/install_aws_tools.sh && \
bash bootstrap/install_iac.sh && \
bash bootstrap/install_devtools.sh && \
bash bootstrap/post_install.sh

# Restart your terminal or source zsh
source ~/.zshrc
```

**Time:** ~20-30 minutes depending on internet speed.

## What Gets Installed

### Core Tools
- **Homebrew** - Package manager with architecture detection
- **CLI utilities** - git, gh, jq, yq, curl, wget, direnv, make

### Language Runtimes
- **Python** - pyenv + Python 3.12 + pipx + Poetry
- **Node.js** - nvm + LTS + pnpm
- **Java** - OpenJDK 21 (Temurin)

### AWS Tools
- AWS CLI v2
- AWS SAM CLI
- AWS CDK v2
- AWS Session Manager Plugin
- aws-vault (credential management)
- aws-sso-util

### Infrastructure as Code
- **Terraform** - via tfenv (version manager)
- **Terragrunt** - via tgenv
- **Linting** - tflint, tfsec, checkov, terraform-docs

### Development & Security
- **Docker** - Docker Desktop + Colima (lightweight alternative)
- **Security** - sops, age, gitleaks
- **Linters** - pre-commit, ruff, black, isort, shellcheck, hadolint

### Python AI/ML Environment
Pre-configured Poetry project with:
- boto3 + type stubs for Bedrock & SageMaker
- sagemaker SDK
- pandas, numpy, matplotlib
- jupyterlab + ipykernel
- langchain + langchain-aws
- fastapi + uvicorn

## Repository Structure

```
.
├── bootstrap/          # Installation scripts
├── ai/                 # Python AI/ML project
│   ├── src/           # Example scripts for Bedrock & SageMaker
│   └── notebooks/     # Jupyter notebooks
├── docker/            # SageMaker inference containers
├── infra/             # Terraform modules
│   └── modules/       # Backend, ECR, IAM, VPC
├── terragrunt/        # Live configs for dev/prod
├── .vscode/           # VS Code configuration
├── .devcontainer/     # Dev container support
├── .github/workflows/ # CI/CD pipelines
└── docs/              # Detailed documentation
```

## Documentation

Comprehensive guides in the [`docs/`](docs/) folder:

- [00 - Prerequisites](docs/00-prereqs.md) - Mac setup and Homebrew
- [01 - AWS SSO](docs/01-aws-sso.md) - Configure AWS credentials and profiles
- [02 - Python](docs/02-python.md) - pyenv, Poetry, Jupyter
- [03 - Docker](docs/03-docker.md) - Docker Desktop vs Colima, ECR
- [04 - Terraform & Terragrunt](docs/04-terraform-terragrunt.md) - IaC workflow
- [05 - Bedrock](docs/05-bedrock.md) - Foundation models and examples
- [06 - SageMaker](docs/06-sagemaker.md) - Training jobs and endpoints
- [07 - Security](docs/07-security.md) - Secrets management and scanning

## Usage Examples

### Run Bedrock Example

```bash
cd ai
poetry install
poetry run python src/bedrock_example.py
```

### Launch Jupyter Lab

```bash
cd ai
poetry run jupyter lab
# Open notebooks/bedrock_quickstart.ipynb
```

### Build and Push SageMaker Docker Image

```bash
cd docker
make build
make test
make deploy  # Pushes to ECR
```

### Deploy Infrastructure with Terraform

```bash
cd infra
terraform init
terraform plan
terraform apply
```

### Deploy with Terragrunt (Dev Environment)

```bash
cd terragrunt/envs/dev
terragrunt run-all init
terragrunt run-all plan
terragrunt run-all apply
```

## Environment Verification Checklist

After installation, verify your setup:

```bash
# Package managers
brew --version
python --version          # Should be 3.12.x
node --version            # Should be LTS
java -version             # Should be 21

# AWS tools
aws --version
sam --version
cdk --version
terraform --version
terragrunt --version

# Docker
docker --version
colima status             # If using Colima

# Python environment
cd ai && poetry env info

# Pre-commit
pre-commit --version

# VS Code extensions (open VS Code)
code --list-extensions | grep -E "(copilot|aws|terraform|python)"
```

## Post-Bootstrap Configuration

### 1. Configure AWS Credentials

Choose one method:

**Option A: AWS SSO** (recommended)
```bash
aws configure sso
# Follow prompts
```

**Option B: aws-vault**
```bash
aws-vault add default
aws-vault exec default -- aws sts get-caller-identity
```

See [docs/01-aws-sso.md](docs/01-aws-sso.md) for details.

### 2. Initialize Pre-commit Hooks

```bash
pre-commit install
pre-commit run --all-files  # Test all hooks
```

### 3. Configure Bedrock Model Access

1. Open AWS Console → Bedrock → Model access
2. Request access to models (e.g., Claude 3, Titan)
3. Wait for approval (~5 minutes for most models)

### 4. Create Terraform Backend

```bash
cd infra/modules/backend
terraform init
terraform apply -var="bucket_name=terraform-state-YOUR-ACCOUNT-ID"
```

Then uncomment the backend configuration in `infra/global.tf`.

## CI/CD Pipelines

GitHub Actions workflows included:

- **Terraform Validation** - Runs on PR, validates tf files with tflint, tfsec, checkov
- **Python Lint** - Runs ruff, black, isort, mypy on Python code
- **Docker Build** - (Manual trigger) Builds and pushes SageMaker image to ECR

## VS Code Integration

### Recommended Extensions

Open VS Code and install recommended extensions:
```bash
code .
# Click "Install All" when prompted
```

Includes:
- GitHub Copilot & Copilot Chat
- AWS Toolkit
- HashiCorp Terraform
- Python + Pylance
- Docker
- Jupyter

### Settings

Format-on-save enabled for:
- Python (via Ruff)
- Terraform (via Terraform extension)
- Markdown, JSON, YAML

## Cost Optimization Tips

1. **Use Spot Instances** for SageMaker training (up to 70% savings)
2. **Delete endpoints** immediately after testing
3. **Enable S3 lifecycle policies** for model artifacts
4. **Use VPC endpoints** for S3 (avoid NAT charges)
5. **Tag all resources** for cost allocation

See [docs/06-sagemaker.md](docs/06-sagemaker.md) for detailed cost tips.

## Troubleshooting

### Common Issues

**Python version mismatch**
```bash
pyenv global 3.12
pyenv rehash
```

**Docker not starting**
```bash
# If using Colima
colima start --cpu 4 --memory 8
```

**Terraform state lock errors**
```bash
# Release lock manually
aws dynamodb delete-item \
  --table-name terraform-state-lock \
  --key '{"LockID":{"S":"<lock-id>"}}'
```

**Bedrock permission errors**
- Check IAM permissions for `bedrock:InvokeModel`
- Verify model access in Bedrock console

## Architecture Support

✅ **Apple Silicon (M1/M2/M3)** - Fully supported
✅ **Intel Mac** - Fully supported
✅ **Rosetta 2** - Auto-installed on Apple Silicon when needed

## Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Security

- **No secrets committed** - Use `.env` files (see `.env.example`)
- **Pre-commit hooks** - Gitleaks scans for secrets
- **Encrypted state** - S3 backend with encryption
- **IAM least privilege** - Minimal permissions in Terraform modules

## License

MIT License - see [LICENSE](LICENSE) for details.

## Maintenance

### Update Tools

```bash
# Homebrew packages
brew update && brew upgrade

# Python packages
cd ai && poetry update

# Terraform/Terragrunt
tfenv install latest && tfenv use latest
tgenv install latest && tgenv use latest

# Pre-commit hooks
pre-commit autoupdate
```

## Resources

- [AWS Bedrock Documentation](https://docs.aws.amazon.com/bedrock/)
- [Amazon SageMaker Documentation](https://docs.aws.amazon.com/sagemaker/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terragrunt Documentation](https://terragrunt.gruntwork.io/)

## Support

- 📖 [Documentation](docs/)
- 🐛 [Issues](https://github.com/YOUR-USERNAME/aws-mac-bootstrap-bedrock-sagemaker/issues)
- 💬 [Discussions](https://github.com/YOUR-USERNAME/aws-mac-bootstrap-bedrock-sagemaker/discussions)

---

**Built with ❤️ for AWS Solutions Architects**
