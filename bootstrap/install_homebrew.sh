#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Copyright (c) 2025 Nour Al Bakour
#
# install_homebrew.sh
# Installs Homebrew on macOS (Apple Silicon or Intel)
#

set -euo pipefail

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Installing Homebrew"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Detect architecture
ARCH=$(uname -m)
echo "→ Detected architecture: ${ARCH}"

# Install Rosetta 2 for Apple Silicon if needed
if [[ "${ARCH}" == "arm64" ]]; then
  if ! /usr/bin/pgrep -q oahd; then
    echo "→ Installing Rosetta 2 for Apple Silicon compatibility..."
    softwareupdate --install-rosetta --agree-to-license
  else
    echo "✓ Rosetta 2 already installed"
  fi
fi

# Install Homebrew if not present
if ! command -v brew &>/dev/null; then
  echo "→ Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  # Add Homebrew to PATH for Apple Silicon
  if [[ "${ARCH}" == "arm64" ]]; then
    echo "→ Adding Homebrew to PATH in ~/.zshrc for Apple Silicon..."
    if ! grep -q '/opt/homebrew/bin/brew' ~/.zshrc 2>/dev/null; then
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  else
    # Intel Mac
    if ! grep -q '/usr/local/bin/brew' ~/.zshrc 2>/dev/null; then
      echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zshrc
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi
else
  echo "✓ Homebrew already installed"
fi

# Update Homebrew
echo "→ Updating Homebrew..."
brew update

# Add useful taps
echo "→ Adding Homebrew taps..."
brew tap aws/tap || true
brew tap hashicorp/tap || true

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Homebrew installation complete!"
echo "  Version: $(brew --version | head -n1)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
