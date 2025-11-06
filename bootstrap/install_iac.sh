#!/usr/bin/env bash
#
# install_iac.sh
# Installs Terraform, Terragrunt, and IaC linting/security tools
#

set -euo pipefail

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Installing Infrastructure as Code Tools"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ============================================================================
# tfenv (Terraform version manager)
# ============================================================================
if ! command -v tfenv &>/dev/null; then
  echo "→ Installing tfenv..."
  brew install tfenv
else
  echo "✓ tfenv already installed"
fi

# Install latest Terraform
echo "→ Installing latest Terraform via tfenv..."
tfenv install latest
tfenv use latest

# ============================================================================
# tgenv (Terragrunt version manager)
# ============================================================================
if ! command -v tgenv &>/dev/null; then
  echo "→ Installing tgenv..."
  brew install tgenv
else
  echo "✓ tgenv already installed"
fi

# Install latest Terragrunt
echo "→ Installing latest Terragrunt via tgenv..."
tgenv install latest
tgenv use latest

# ============================================================================
# Terraform linting and security tools
# ============================================================================
TOOLS=(
  tflint          # Terraform linter
  tfsec           # Terraform security scanner
  checkov         # IaC security scanner
  terraform-docs  # Generate Terraform docs
)

for tool in "${TOOLS[@]}"; do
  if brew list "${tool}" &>/dev/null; then
    echo "✓ ${tool} already installed"
  else
    echo "→ Installing ${tool}..."
    brew install "${tool}"
  fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ IaC tools installation complete!"
echo "  Terraform:      $(terraform version | head -n1)"
echo "  Terragrunt:     $(terragrunt --version | head -n1)"
echo "  tflint:         $(tflint --version)"
echo "  tfsec:          $(tfsec --version)"
echo "  checkov:        $(checkov --version)"
echo "  terraform-docs: $(terraform-docs --version)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
