#!/usr/bin/env bash
#
# install_langs.sh
# Installs Python, Node.js, and Java toolchains
#

set -euo pipefail

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Installing Language Toolchains"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ============================================================================
# Python with pyenv
# ============================================================================
echo ""
echo "→ Installing Python toolchain (pyenv, Python 3.12, pipx, poetry)..."

if ! command -v pyenv &>/dev/null; then
  brew install pyenv
else
  echo "✓ pyenv already installed"
fi

# Add pyenv init to zshrc
if ! grep -q 'pyenv init' ~/.zshrc 2>/dev/null; then
  echo '' >> ~/.zshrc
  echo '# pyenv' >> ~/.zshrc
  echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
  echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
  echo 'eval "$(pyenv init --path)"' >> ~/.zshrc
  echo 'eval "$(pyenv init -)"' >> ~/.zshrc
fi

# Source pyenv for current session
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)" 2>/dev/null || true
eval "$(pyenv init -)" 2>/dev/null || true

# Install Python 3.12 if not present
PYTHON_VERSION="3.12"
if ! pyenv versions | grep -q "${PYTHON_VERSION}"; then
  echo "→ Installing Python ${PYTHON_VERSION}..."
  pyenv install "${PYTHON_VERSION}:latest"
fi

# Set global Python version
LATEST_312=$(pyenv versions --bare | grep "^3.12" | tail -n1)
echo "→ Setting global Python to ${LATEST_312}..."
pyenv global "${LATEST_312}"

# Install pipx and poetry
if ! command -v pipx &>/dev/null; then
  brew install pipx
  pipx ensurepath
else
  echo "✓ pipx already installed"
fi

if ! command -v poetry &>/dev/null; then
  pipx install poetry
else
  echo "✓ poetry already installed"
fi

# ============================================================================
# Node.js with nvm
# ============================================================================
echo ""
echo "→ Installing Node.js toolchain (nvm, Node LTS, pnpm)..."

NVM_DIR="$HOME/.nvm"
if [[ ! -d "${NVM_DIR}" ]]; then
  echo "→ Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
else
  echo "✓ nvm already installed"
fi

# Add nvm to zshrc if not present
if ! grep -q 'NVM_DIR' ~/.zshrc 2>/dev/null; then
  echo '' >> ~/.zshrc
  echo '# nvm' >> ~/.zshrc
  echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
  echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.zshrc
  echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.zshrc
fi

# Source nvm for current session
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node LTS
echo "→ Installing Node.js LTS..."
nvm install --lts
nvm use --lts
nvm alias default "lts/*"

# Install pnpm
if ! command -v pnpm &>/dev/null; then
  npm install -g pnpm
else
  echo "✓ pnpm already installed"
fi

# ============================================================================
# Java with Temurin
# ============================================================================
echo ""
echo "→ Installing Java toolchain (Temurin JDK 21)..."

if ! brew list openjdk@21 &>/dev/null; then
  brew install openjdk@21
else
  echo "✓ openjdk@21 already installed"
fi

# Add Java to PATH
if ! grep -q 'openjdk@21' ~/.zshrc 2>/dev/null; then
  echo '' >> ~/.zshrc
  echo '# Java (OpenJDK 21)' >> ~/.zshrc
  echo 'export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"' >> ~/.zshrc
  echo 'export JAVA_HOME="/opt/homebrew/opt/openjdk@21"' >> ~/.zshrc
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Language toolchains installation complete!"
echo "  Python: $(python --version 2>&1 || echo 'restart shell')"
echo "  Node:   $(node --version 2>&1 || echo 'restart shell')"
echo "  Java:   $(java -version 2>&1 | head -n1 || echo 'restart shell')"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
