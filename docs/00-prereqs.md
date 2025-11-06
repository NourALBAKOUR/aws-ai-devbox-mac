# 00 - Prerequisites and Mac Setup

## System Requirements

- **macOS:** 12 (Monterey) or later
- **Architecture:** Apple Silicon (M1/M2/M3) or Intel
- **RAM:** 8GB minimum, 16GB+ recommended
- **Storage:** 50GB free space
- **Network:** Broadband internet for downloads

## Before You Begin

### 1. Check macOS Version

```bash
sw_vers
```

Expected output:
```
ProductName:    macOS
ProductVersion: 14.x.x
BuildVersion:   ...
```

### 2. Check Architecture

```bash
uname -m
```

- `arm64` = Apple Silicon
- `x86_64` = Intel

### 3. Enable Command Line Tools

```bash
xcode-select --install
```

Click "Install" when prompted. This installs git and other essentials.

## Homebrew Installation

Homebrew is the package manager for macOS. Our bootstrap script installs it automatically, but you can also install manually:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Post-Installation (Apple Silicon)

For M1/M2/M3 Macs, add Homebrew to PATH:

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
source ~/.zshrc
```

### Verify Installation

```bash
brew --version
brew doctor
```

## Terminal Setup

### Default Shell (zsh)

macOS uses zsh by default. Verify:

```bash
echo $SHELL
# Should output: /bin/zsh
```

### iTerm2 (Optional but Recommended)

Better terminal with more features:

```bash
brew install --cask iterm2
```

### Oh My Zsh (Optional)

Enhance zsh with themes and plugins:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## Network Configuration

### Check Internet Connection

```bash
ping -c 3 google.com
```

### Corporate Proxy (If Applicable)

Add to `~/.zshrc`:

```bash
export http_proxy="http://proxy.company.com:8080"
export https_proxy="http://proxy.company.com:8080"
export no_proxy="localhost,127.0.0.1"
```

## Security Settings

### Allow Apps from Anywhere

Some tools require this:

```bash
sudo spctl --master-disable
```

**Note:** Re-enable after bootstrap: `sudo spctl --master-enable`

### Firewall

Enable macOS firewall:
```
System Settings → Network → Firewall → Turn On
```

## Disk Space Management

### Check Available Space

```bash
df -h
```

### Clear Space if Needed

```bash
# Clear Homebrew cache
brew cleanup --prune=all

# Clear system cache (requires restart)
sudo rm -rf /Library/Caches/*

# Empty trash
rm -rf ~/.Trash/*
```

## AWS Account Prerequisites

### Required AWS Services

Ensure your AWS account has access to:
- Amazon Bedrock
- Amazon SageMaker
- Amazon S3
- Amazon ECR
- AWS IAM

### IAM Permissions

Minimum IAM permissions needed:
- `AmazonBedrockFullAccess` (or limited model access)
- `AmazonSageMakerFullAccess`
- `AmazonS3FullAccess` (or bucket-specific)
- `AmazonEC2ContainerRegistryPowerUser`
- `IAMReadOnlyAccess`

### AWS Organizations (Optional)

If using AWS Organizations, ensure:
- Service Control Policies allow Bedrock and SageMaker
- No region restrictions on required regions

## SSH Keys for GitHub

Generate SSH key:

```bash
ssh-keygen -t ed25519 -C "your-email@example.com"
```

Add to GitHub:
```bash
pbcopy < ~/.ssh/id_ed25519.pub
# Paste in GitHub Settings → SSH Keys
```

Test connection:
```bash
ssh -T git@github.com
```

## Time Sync

Ensure system time is accurate:

```bash
sudo sntp -sS time.apple.com
```

## Ready to Bootstrap

Once prerequisites are met, proceed to run the bootstrap scripts:

```bash
cd aws-mac-bootstrap-bedrock-sagemaker
bash bootstrap/install_homebrew.sh
```

---

**Next:** [01 - AWS SSO Configuration](01-aws-sso.md)
