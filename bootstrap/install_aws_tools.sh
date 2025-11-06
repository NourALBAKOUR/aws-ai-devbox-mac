#!/usr/bin/env bash
#
# install_aws_tools.sh
# Installs AWS CLI v2, SAM CLI, CDK, session-manager-plugin, aws-vault, etc.
#

set -euo pipefail

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Installing AWS Tools"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ============================================================================
# AWS CLI v2
# ============================================================================
if ! command -v aws &>/dev/null; then
  echo "→ Installing AWS CLI v2..."
  brew install awscli
else
  echo "✓ AWS CLI already installed"
fi

# Add AWS CLI completion to zshrc
if ! grep -q 'aws_completer' ~/.zshrc 2>/dev/null; then
  echo '' >> ~/.zshrc
  echo '# AWS CLI completion' >> ~/.zshrc
  echo 'autoload -Uz compinit && compinit' >> ~/.zshrc
  echo 'complete -C "$(which aws_completer)" aws' >> ~/.zshrc
fi

# ============================================================================
# AWS Session Manager Plugin
# ============================================================================
if ! command -v session-manager-plugin &>/dev/null; then
  echo "→ Installing AWS Session Manager Plugin..."
  brew install --cask session-manager-plugin
else
  echo "✓ AWS Session Manager Plugin already installed"
fi

# ============================================================================
# AWS SAM CLI
# ============================================================================
if ! command -v sam &>/dev/null; then
  echo "→ Installing AWS SAM CLI..."
  brew tap aws/tap
  brew install aws-sam-cli
else
  echo "✓ AWS SAM CLI already installed"
fi

# ============================================================================
# AWS CDK v2
# ============================================================================
if ! command -v cdk &>/dev/null; then
  echo "→ Installing AWS CDK v2..."
  npm install -g aws-cdk
else
  echo "✓ AWS CDK already installed"
fi

# ============================================================================
# CDKTF (CDK for Terraform)
# ============================================================================
if ! command -v cdktf &>/dev/null; then
  echo "→ Installing CDKTF..."
  npm install -g cdktf-cli
else
  echo "✓ CDKTF already installed"
fi

# ============================================================================
# aws-vault (secure credential management)
# ============================================================================
if ! command -v aws-vault &>/dev/null; then
  echo "→ Installing aws-vault..."
  brew install aws-vault
else
  echo "✓ aws-vault already installed"
fi

# ============================================================================
# aws-sso-util (AWS SSO helper)
# ============================================================================
if ! command -v aws-sso-util &>/dev/null; then
  echo "→ Installing aws-sso-util..."
  brew install aws-sso-util
else
  echo "✓ aws-sso-util already installed"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ AWS tools installation complete!"
echo "  AWS CLI:     $(aws --version 2>&1 | cut -d' ' -f1)"
echo "  SAM CLI:     $(sam --version 2>&1 || echo 'restart shell')"
echo "  CDK:         $(cdk --version 2>&1 || echo 'restart shell')"
echo "  aws-vault:   $(aws-vault --version 2>&1 || echo 'installed')"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
