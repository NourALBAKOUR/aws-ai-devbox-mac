#!/usr/bin/env bash
#
# install_devtools.sh
# Installs Docker, security tools, linters, and development utilities
#

set -euo pipefail

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Installing Development Tools"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ============================================================================
# Docker Desktop and Colima
# ============================================================================
echo "→ Installing Docker Desktop (you can also use Colima as alternative)..."
if ! brew list --cask docker &>/dev/null; then
  brew install --cask docker
else
  echo "✓ Docker Desktop already installed"
fi

# Install Colima as lightweight alternative
if ! command -v colima &>/dev/null; then
  echo "→ Installing Colima (lightweight Docker alternative)..."
  brew install colima docker docker-compose
else
  echo "✓ Colima already installed"
fi

# ============================================================================
# Security and secrets management
# ============================================================================
echo ""
echo "→ Installing security tools (sops, age, gitleaks)..."

SECURITY_TOOLS=(
  sops       # Secrets encryption
  age        # Encryption tool for sops
  gitleaks   # Secret scanning
)

for tool in "${SECURITY_TOOLS[@]}"; do
  if brew list "${tool}" &>/dev/null; then
    echo "✓ ${tool} already installed"
  else
    echo "→ Installing ${tool}..."
    brew install "${tool}"
  fi
done

# ============================================================================
# Linters and formatters
# ============================================================================
echo ""
echo "→ Installing linters and formatters..."

LINT_TOOLS=(
  pre-commit    # Git pre-commit hooks
  ruff          # Fast Python linter
  black         # Python formatter
  isort         # Python import sorter
  shellcheck    # Shell script linter
  hadolint      # Dockerfile linter
)

for tool in "${LINT_TOOLS[@]}"; do
  if brew list "${tool}" &>/dev/null; then
    echo "✓ ${tool} already installed"
  else
    echo "→ Installing ${tool}..."
    brew install "${tool}"
  fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Development tools installation complete!"
echo "  Docker:      $(docker --version 2>&1 || echo 'restart Docker Desktop')"
echo "  Colima:      $(colima --version 2>&1)"
echo "  sops:        $(sops --version 2>&1)"
echo "  gitleaks:    $(gitleaks version 2>&1)"
echo "  pre-commit:  $(pre-commit --version 2>&1)"
echo "  ruff:        $(ruff --version 2>&1)"
echo "  shellcheck:  $(shellcheck --version | head -n2 | tail -n1)"
echo "  hadolint:    $(hadolint --version 2>&1)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
