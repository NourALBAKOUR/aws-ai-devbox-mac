# 01 - AWS SSO and Credential Management

## Overview

Secure credential management is critical. This guide covers:
- AWS IAM Identity Center (SSO)
- aws-vault for credential isolation
- Named profiles for multiple accounts

## AWS IAM Identity Center (SSO)

### Prerequisites

- AWS Organizations enabled
- IAM Identity Center configured
- SSO start URL and region

### Configure AWS SSO

```bash
aws configure sso
```

Follow prompts:
```
SSO session name: my-sso
SSO start URL: https://d-xxxxxxxxxx.awsapps.com/start
SSO region: us-east-1
SSO registration scopes: sso:account:access
```

Browser opens → Sign in → Allow access

```
CLI default client Region: us-east-1
CLI default output format: json
CLI profile name: default
```

### Verify SSO Login

```bash
aws sso login --profile default
aws sts get-caller-identity --profile default
```

Expected output:
```json
{
    "UserId": "AROAXXXXXXXXXXXXXXXXX:user@example.com",
    "Account": "123456789012",
    "Arn": "arn:aws:sts::123456789012:assumed-role/RoleName/user@example.com"
}
```

### Configure Multiple Accounts

Edit `~/.aws/config`:

```ini
[profile dev]
sso_session = my-sso
sso_account_id = 111111111111
sso_role_name = PowerUserAccess
region = us-east-1
output = json

[profile prod]
sso_session = my-sso
sso_account_id = 222222222222
sso_role_name = ReadOnlyAccess
region = us-east-1
output = json

[sso-session my-sso]
sso_start_url = https://d-xxxxxxxxxx.awsapps.com/start
sso_region = us-east-1
sso_registration_scopes = sso:account:access
```

Use profiles:
```bash
aws s3 ls --profile dev
aws s3 ls --profile prod
```

### Auto-Refresh SSO Token

Add to `~/.zshrc`:

```bash
# Auto-refresh SSO token before commands
aws-sso-refresh() {
  if ! aws sts get-caller-identity --profile $AWS_PROFILE &>/dev/null; then
    aws sso login --profile $AWS_PROFILE
  fi
}

# Set default profile
export AWS_PROFILE=dev
```

## aws-vault (Alternative Method)

aws-vault stores credentials securely in macOS Keychain.

### Install (Already Included)

```bash
brew install aws-vault
```

### Add Credentials

```bash
aws-vault add default
```

Enter Access Key ID and Secret Access Key when prompted.

### Execute Commands

```bash
aws-vault exec default -- aws s3 ls
```

### Login for Duration

```bash
aws-vault exec default --duration=12h
```

### GUI Login

```bash
aws-vault login default
```

Opens browser with AWS Console access.

### Multiple Profiles

Add profiles:
```bash
aws-vault add dev
aws-vault add prod
```

List profiles:
```bash
aws-vault list
```

## Environment Variables

### Option 1: direnv (Recommended)

Create `.envrc` in project root:

```bash
export AWS_PROFILE=dev
export AWS_REGION=us-east-1
```

Allow directory:
```bash
direnv allow
```

Auto-loads when entering directory.

### Option 2: Manual Export

Add to `~/.zshrc`:

```bash
export AWS_PROFILE=dev
export AWS_REGION=us-east-1
export AWS_DEFAULT_REGION=us-east-1
```

### Option 3: .env File

Create `.env`:
```bash
AWS_PROFILE=dev
AWS_REGION=us-east-1
```

Load with:
```bash
source .env
```

Or use in Python:
```python
from dotenv import load_dotenv
load_dotenv()
```

## Named Profiles in Code

### AWS CLI

```bash
aws s3 ls --profile dev
aws s3 ls --profile prod
```

### Boto3 (Python)

```python
import boto3

session = boto3.Session(profile_name='dev')
s3 = session.client('s3')
```

### AWS CDK

```bash
cdk deploy --profile dev
cdk deploy --profile prod
```

### Terraform

```hcl
provider "aws" {
  profile = "dev"
  region  = "us-east-1"
}
```

Or use environment variable:
```bash
export AWS_PROFILE=dev
terraform apply
```

## MFA with aws-vault

Add MFA ARN to `~/.aws/config`:

```ini
[profile dev]
mfa_serial = arn:aws:iam::123456789012:mfa/user-name
```

aws-vault will prompt for MFA token:
```bash
aws-vault exec dev -- aws s3 ls
# Enter MFA code: 123456
```

## Temporary Credentials

Get temporary credentials:

```bash
aws sts get-session-token --duration-seconds 3600
```

Or with MFA:
```bash
aws sts get-session-token \
  --serial-number arn:aws:iam::123456789012:mfa/user \
  --token-code 123456 \
  --duration-seconds 43200
```

## Testing Bedrock Access

```bash
aws bedrock list-foundation-models --region us-east-1
```

## Testing SageMaker Access

```bash
aws sagemaker list-notebook-instances
```

## Security Best Practices

1. **Never commit credentials** - Use `.gitignore`
2. **Use IAM roles** when possible (EC2, Lambda, ECS)
3. **Rotate keys regularly** (90 days)
4. **Use least privilege** - Only grant needed permissions
5. **Enable MFA** for production accounts
6. **Use aws-vault or SSO** - Avoid long-lived credentials in `~/.aws/credentials`

## Troubleshooting

### Token Expired

```bash
# SSO
aws sso login --profile dev

# aws-vault
aws-vault exec dev --duration=12h
```

### Wrong Account

```bash
aws sts get-caller-identity
# Verify Account ID
```

### Permission Denied

Check IAM permissions:
```bash
aws iam get-user
aws iam list-attached-user-policies --user-name your-user
```

### Region Mismatch

```bash
export AWS_REGION=us-east-1
# Or
aws configure set region us-east-1 --profile dev
```

---

**Next:** [02 - Python Environment](02-python.md)
