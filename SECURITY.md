# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please report it by:

1. **Do NOT** open a public issue
2. Email the maintainer directly or use GitHub's private vulnerability reporting
3. Provide detailed information about the vulnerability:
   - Description of the issue
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

## Supported Versions

We support the latest version of this project. Security updates will be applied to the main branch.

| Version | Supported          |
| ------- | ------------------ |
| main    | :white_check_mark: |
| older   | :x:                |

## Security Best Practices

When using this repository:

1. **AWS Credentials**: Never commit AWS credentials to version control
   - Use `aws-vault` for credential management
   - Configure AWS SSO for secure access
   - Keep credentials in `~/.aws/` directory (which is gitignored)

2. **Secrets Management**: 
   - Use `sops` with `age` or AWS KMS for encrypting secrets
   - Never store plaintext secrets in Terraform files
   - Use environment variables or AWS Secrets Manager

3. **Docker Security**:
   - Regularly update base images
   - Scan images with `docker scan` or `trivy`
   - Use `.dockerignore` to prevent sensitive files from being included

4. **Terraform Security**:
   - Use `tfsec` and `checkov` to scan for security issues
   - Enable S3 bucket encryption for Terraform state
   - Use DynamoDB state locking to prevent concurrent modifications

5. **Dependencies**:
   - Regularly update dependencies with `brew upgrade` and `poetry update`
   - Review security advisories for installed packages
   - Use `gitleaks` to scan for accidentally committed secrets

## Tools Included for Security

This project includes several security tools:

- **gitleaks**: Scan for secrets in git history
- **sops**: Encrypt/decrypt secrets
- **age**: Modern encryption tool
- **tfsec**: Terraform security scanner
- **checkov**: Infrastructure as code security scanner
- **pre-commit**: Git hooks for security checks

Run security scans before committing:

```bash
# Scan for secrets
gitleaks detect

# Scan Terraform
cd infra
tfsec .
checkov -d .
```

## Response Timeline

- **Critical vulnerabilities**: Response within 24 hours
- **High severity**: Response within 1 week
- **Medium/Low severity**: Response within 2 weeks

Thank you for helping keep this project secure!
