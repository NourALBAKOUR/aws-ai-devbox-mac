#!/usr/bin/env bash
#
# post_install.sh
# Post-installation steps: create directories, show summary, next steps
#

set -euo pipefail

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Post-Installation Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ============================================================================
# Create AWS config directory
# ============================================================================
echo "→ Creating ~/.aws directory..."
mkdir -p ~/.aws
touch ~/.aws/config
touch ~/.aws/credentials

# ============================================================================
# Initialize Poetry project in ai/ directory
# ============================================================================
if [[ -f "ai/pyproject.toml" ]]; then
  echo "→ Installing Python dependencies with Poetry..."
  cd ai
  poetry install
  
  # Register Jupyter kernel
  echo "→ Registering Jupyter kernel 'ai-env'..."
  poetry run python -m ipykernel install --user --name=ai-env --display-name="Python (AI/ML)"
  cd ..
else
  echo "⚠ Skipping Poetry install (run from repo root or ai/ dir doesn't exist)"
fi

# ============================================================================
# Summary
# ============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Bootstrap complete! Restart your terminal or run:"
echo ""
echo "    source ~/.zshrc"
echo ""
echo "Next steps:"
echo "  1. Configure AWS credentials (see docs/01-aws-sso.md)"
echo "  2. Set up GitHub access: gh auth login"
echo "  3. Initialize pre-commit: cd <repo> && pre-commit install"
echo "  4. Start Docker Desktop or Colima: colima start"
echo "  5. Initialize Terraform backend: cd infra && terraform init"
echo "  6. Open VS Code and install recommended extensions"
echo ""
echo "Documentation: See docs/ folder for detailed guides"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
