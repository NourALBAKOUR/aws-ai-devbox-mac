# 07 - Security and Secrets Management

## Overview

Security layers:
- **Secrets management** - sops + age, AWS Secrets Manager
- **Secret scanning** - gitleaks
- **Pre-commit hooks** - Automated checks
- **IAM best practices** - Least privilege
- **Encryption** - At rest and in transit

## SOPS (Secrets OPerationS)

SOPS encrypts files with your keys while keeping structure readable.

### Install (Already Included)

```bash
brew install sops age
```

### Generate Age Key

```bash
age-keygen -o ~/.age/key.txt
```

Output:
```
# created: 2025-01-01T00:00:00Z
# public key: age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
AGE-SECRET-KEY-1XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

Save public key for `.sops.yaml`.

### Create .sops.yaml

```yaml
creation_rules:
  - path_regex: \.env$
    age: age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  - path_regex: secrets/.*\.yaml$
    age: age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### Encrypt File

```bash
# Encrypt in place
sops -e -i secrets/production.env

# Encrypt to new file
sops -e secrets/production.env > secrets/production.enc.env
```

### Decrypt File

```bash
# Decrypt to stdout
sops -d secrets/production.env

# Decrypt in place
sops -d -i secrets/production.env
```

### Edit Encrypted File

```bash
sops secrets/production.env
# Opens in editor, auto-encrypts on save
```

### Use in Scripts

```bash
# Export decrypted variables
export $(sops -d secrets/production.env | xargs)

# Pass to command
sops exec-env secrets/production.env 'terraform apply'
```

## AWS Secrets Manager

For application secrets:

### Store Secret

```bash
aws secretsmanager create-secret \
  --name prod/database/password \
  --secret-string "my-password"
```

### Retrieve Secret

```bash
aws secretsmanager get-secret-value \
  --secret-id prod/database/password \
  --query SecretString \
  --output text
```

### Use in Python

```python
import boto3
import json

client = boto3.client("secretsmanager")

response = client.get_secret_value(SecretId="prod/database/password")
secret = json.loads(response["SecretString"])
password = secret["password"]
```

### Rotation

```bash
aws secretsmanager rotate-secret \
  --secret-id prod/database/password \
  --rotation-lambda-arn arn:aws:lambda:...
```

## AWS Systems Manager Parameter Store

For configuration values:

### Store Parameter

```bash
aws ssm put-parameter \
  --name /app/prod/api-key \
  --value "abc123" \
  --type SecureString
```

### Retrieve Parameter

```bash
aws ssm get-parameter \
  --name /app/prod/api-key \
  --with-decryption \
  --query Parameter.Value \
  --output text
```

### Use in Python

```python
import boto3

ssm = boto3.client("ssm")

response = ssm.get_parameter(
    Name="/app/prod/api-key",
    WithDecryption=True
)
api_key = response["Parameter"]["Value"]
```

## Gitleaks - Secret Scanning

Prevents committing secrets to git.

### Verify Installation

```bash
gitleaks version
```

### Scan Repository

```bash
# Scan all history
gitleaks detect --source . --verbose

# Scan uncommitted changes
gitleaks protect --staged

# Scan specific file
gitleaks detect --source . --file path/to/file
```

### Configuration

`.gitleaks.toml`:

```toml
title = "Gitleaks Config"

[[rules]]
description = "AWS Access Key"
id = "aws-access-key"
regex = '''(A3T[A-Z0-9]|AKIA|AGPA|AIDA|AROA|AIPA|ANPA|ANVA|ASIA)[A-Z0-9]{16}'''
tags = ["key", "AWS"]

[[rules]]
description = "AWS Secret Key"
id = "aws-secret-key"
regex = '''(?i)aws(.{0,20})?(?-i)['\"][0-9a-zA-Z\/+]{40}['\"]'''
tags = ["key", "AWS"]

[allowlist]
paths = ['''.env.example$''']
```

### Fix Leaked Secrets

If secret committed:

1. **Rotate secret immediately**
   ```bash
   aws iam create-access-key --user-name myuser
   aws iam delete-access-key --access-key-id OLD_KEY --user-name myuser
   ```

2. **Remove from git history**
   ```bash
   git filter-branch --force --index-filter \
     'git rm --cached --ignore-unmatch path/to/file' \
     --prune-empty --tag-name-filter cat -- --all
   ```

3. **Force push** (⚠️ destructive)
   ```bash
   git push origin --force --all
   ```

## Pre-commit Hooks

Automated checks before each commit.

### Install Hooks

```bash
pre-commit install
```

### Run Manually

```bash
# All files
pre-commit run --all-files

# Specific hook
pre-commit run gitleaks --all-files
```

### Skip Hooks (Emergency)

```bash
git commit --no-verify
```

### Update Hooks

```bash
pre-commit autoupdate
```

## IAM Best Practices

### 1. Least Privilege

Grant minimum required permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel",
        "sagemaker:DescribeEndpoint",
        "sagemaker:InvokeEndpoint"
      ],
      "Resource": [
        "arn:aws:bedrock:us-east-1::foundation-model/*",
        "arn:aws:sagemaker:us-east-1:ACCOUNT:endpoint/my-endpoint"
      ]
    }
  ]
}
```

### 2. Use IAM Roles

For EC2, Lambda, ECS - never use long-lived keys.

### 3. Enable MFA

```bash
aws iam enable-mfa-device \
  --user-name myuser \
  --serial-number arn:aws:iam::ACCOUNT:mfa/myuser \
  --authentication-code1 123456 \
  --authentication-code2 789012
```

### 4. Rotate Keys Regularly

```bash
# Create new key
aws iam create-access-key --user-name myuser

# Delete old key after testing
aws iam delete-access-key --access-key-id OLD_KEY --user-name myuser
```

### 5. Use AWS Organizations SCPs

Service Control Policies restrict across accounts:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "aws:RequestedRegion": ["us-east-1", "us-west-2"]
        }
      }
    }
  ]
}
```

## Encryption

### S3 Encryption

```hcl
resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.example.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

### EBS Encryption

```hcl
resource "aws_ebs_volume" "example" {
  encrypted = true
  kms_key_id = aws_kms_key.example.arn
}
```

### KMS Keys

```bash
# Create key
aws kms create-key --description "SageMaker encryption key"

# Create alias
aws kms create-alias \
  --alias-name alias/sagemaker \
  --target-key-id <key-id>
```

## VPC Security

### Security Groups

```hcl
resource "aws_security_group" "sagemaker" {
  name   = "sagemaker-sg"
  vpc_id = aws_vpc.main.id

  # Allow HTTPS to AWS services
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### VPC Endpoints

Avoid internet gateway charges and increase security:

```bash
aws ec2 create-vpc-endpoint \
  --vpc-id vpc-xxx \
  --service-name com.amazonaws.us-east-1.s3 \
  --route-table-ids rtb-xxx
```

## Audit and Compliance

### CloudTrail

Enable API logging:

```bash
aws cloudtrail create-trail \
  --name my-trail \
  --s3-bucket-name my-cloudtrail-bucket
```

### Config Rules

Monitor compliance:

```bash
aws configservice put-config-rule \
  --config-rule file://s3-bucket-encryption.json
```

### Access Analyzer

Find unintended access:

```bash
aws accessanalyzer create-analyzer \
  --analyzer-name my-analyzer \
  --type ACCOUNT
```

## Security Checklist

- [ ] No secrets in git (use `.gitignore`)
- [ ] Pre-commit hooks installed
- [ ] Gitleaks scanning enabled
- [ ] AWS keys rotated regularly (90 days)
- [ ] MFA enabled for IAM users
- [ ] IAM roles used instead of keys where possible
- [ ] Least privilege IAM policies
- [ ] S3 buckets encrypted
- [ ] CloudTrail enabled
- [ ] VPC endpoints configured
- [ ] Security groups restrictive
- [ ] Secrets Manager for app secrets
- [ ] SOPS for config files
- [ ] Regular security audits

## Incident Response

If secret compromised:

1. **Immediately rotate** credentials
2. **Review CloudTrail** logs for unauthorized access
3. **Check AWS Cost Explorer** for unexpected charges
4. **Remove from git history** if committed
5. **Update documentation** and notify team
6. **Implement additional controls** to prevent recurrence

## Resources

- [AWS Security Best Practices](https://aws.amazon.com/security/best-practices/)
- [SOPS Documentation](https://github.com/mozilla/sops)
- [Gitleaks Documentation](https://github.com/gitleaks/gitleaks)
- [Pre-commit Hooks](https://pre-commit.com/)

---

**End of Documentation**

Return to [README](../README.md) for quick start guide.
