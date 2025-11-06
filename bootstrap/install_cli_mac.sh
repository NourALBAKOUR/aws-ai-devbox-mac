#!/usr/bin/env bash
#
# install_cli_mac.sh
# Installs core CLI tools via Homebrew
#

set -euo pipefail

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Installing Core CLI Tools"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

TOOLS=(
  git
  gh          # GitHub CLI
  jq          # JSON processor
  yq          # YAML processor
  curl
  wget
  direnv      # Environment variable management
  make
  tree
  htop
  watch
)

for tool in "${TOOLS[@]}"; do
  if brew list "${tool}" &>/dev/null; then
    echo "✓ ${tool} already installed"
  else
    echo "→ Installing ${tool}..."
    brew install "${tool}"
  fi
done

# Configure direnv hook for zsh
if ! grep -q 'direnv hook zsh' ~/.zshrc 2>/dev/null; then
  echo "→ Adding direnv hook to ~/.zshrc..."
  echo '' >> ~/.zshrc
  echo '# direnv hook' >> ~/.zshrc
  echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Core CLI tools installation complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
