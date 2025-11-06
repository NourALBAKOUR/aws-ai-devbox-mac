#!/usr/bin/env bash
#
# Bootstrap script for Mac to set up AWS development environment
# Focused on Bedrock and SageMaker development
#

set -euo pipefail

echo "🚀 Starting AWS AI DevBox Mac Bootstrap..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}➜ $1${NC}"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS only!"
    exit 1
fi

print_info "Installing Homebrew..."
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    print_success "Homebrew installed"
else
    print_success "Homebrew already installed"
fi

# Update Homebrew
print_info "Updating Homebrew..."
brew update
print_success "Homebrew updated"

# Install essential tools
print_info "Installing essential development tools..."
brew install git
brew install curl
brew install wget
brew install jq
brew install tree
print_success "Essential tools installed"

# Install AWS CLI
print_info "Installing AWS CLI..."
brew install awscli
print_success "AWS CLI installed"

# Install AWS CDK
print_info "Installing AWS CDK..."
brew install node
npm install -g aws-cdk
print_success "AWS CDK installed"

# Install Terraform
print_info "Installing Terraform..."
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
print_success "Terraform installed"

# Install Terragrunt
print_info "Installing Terragrunt..."
brew install terragrunt
print_success "Terragrunt installed"

# Install Docker
print_info "Installing Docker..."
brew install --cask docker
print_success "Docker installed (Please start Docker Desktop manually)"

# Install Python
print_info "Installing Python..."
brew install python@3.11
print_success "Python installed"

# Install Poetry
print_info "Installing Poetry..."
curl -sSL https://install.python-poetry.org | python3 -
print_success "Poetry installed"

# Add Poetry to PATH for current session
export PATH="$HOME/.local/bin:$PATH"

# Install VS Code
print_info "Installing Visual Studio Code..."
brew install --cask visual-studio-code
print_success "VS Code installed"

# Install VS Code extensions
print_info "Installing VS Code extensions..."
code --install-extension ms-python.python
code --install-extension ms-toolsai.jupyter
code --install-extension hashicorp.terraform
code --install-extension ms-azuretools.vscode-docker
code --install-extension amazonwebservices.aws-toolkit-vscode
code --install-extension ms-vscode-remote.remote-containers
code --install-extension charliermarsh.ruff
print_success "VS Code extensions installed"

# Install pre-commit
print_info "Installing pre-commit..."
brew install pre-commit
print_success "pre-commit installed"

# Configure Git
print_info "Configuring Git..."
if ! git config user.name &> /dev/null; then
    echo "Please enter your Git user name:"
    read git_name
    git config --global user.name "$git_name"
fi

if ! git config user.email &> /dev/null; then
    echo "Please enter your Git email:"
    read git_email
    git config --global user.email "$git_email"
fi
print_success "Git configured"

# Initialize Python Poetry environment
print_info "Setting up Poetry environment..."
if [ -f "pyproject.toml" ]; then
    poetry install
    print_success "Poetry dependencies installed"
else
    print_info "pyproject.toml not found, skipping Poetry install"
fi

# Install pre-commit hooks
if [ -f ".pre-commit-config.yaml" ]; then
    print_info "Installing pre-commit hooks..."
    pre-commit install
    print_success "Pre-commit hooks installed"
fi

echo ""
print_success "🎉 Bootstrap complete!"
echo ""
echo "Next steps:"
echo "1. Start Docker Desktop from Applications"
echo "2. Configure AWS credentials: aws configure"
echo "3. Restart your terminal or run: source ~/.zshrc"
echo "4. Run 'poetry shell' to activate the Python environment"
echo ""
