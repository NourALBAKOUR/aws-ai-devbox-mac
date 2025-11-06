# 04 - Terraform and Terragrunt Workflow

## Overview

Infrastructure as Code (IaC) stack:
- **Terraform** - Resource provisioning
- **Terragrunt** - DRY configuration, remote state management
- **tfenv/tgenv** - Version managers

## Terraform Basics

### Verify Installation

```bash
terraform version
tfenv list
```

### Initialize Project

```bash
cd infra/
terraform init
```

Downloads providers and modules.

### Plan Changes

```bash
terraform plan
terraform plan -out=tfplan
```

Shows what will be created/modified/destroyed.

### Apply Changes

```bash
terraform apply
terraform apply tfplan  # Use saved plan
terraform apply -auto-approve  # Skip confirmation
```

### Destroy Resources

```bash
terraform destroy
terraform destroy -target=aws_instance.example  # Destroy specific resource
```

### Show State

```bash
terraform show
terraform state list
terraform state show aws_s3_bucket.example
```

## Terraform Modules

Our infrastructure is modular:

```
infra/modules/
├── backend/    # S3 + DynamoDB for state
├── ecr/        # Container registry
├── iam/        # Roles for SageMaker/Bedrock
└── vpc/        # Network infrastructure
```

### Using Modules

```hcl
module "vpc" {
  source = "./modules/vpc"
  
  project_name         = "ml-platform"
  vpc_cidr             = "10.0.0.0/16"
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  
  tags = {
    Environment = "dev"
  }
}
```

### Module Outputs

```hcl
output "vpc_id" {
  value = module.vpc.vpc_id
}
```

## Remote State with S3

### Create Backend First

```bash
cd infra/modules/backend
terraform init
terraform apply -var="bucket_name=terraform-state-<account-id>"
```

### Configure Backend

In `infra/global.tf`, uncomment:

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-<account-id>"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

### Migrate State

```bash
terraform init -migrate-state
```

## Terragrunt for DRY Configuration

Terragrunt eliminates code duplication across environments.

### Directory Structure

```
terragrunt/
├── terragrunt.hcl           # Root config
└── envs/
    ├── dev/
    │   └── terragrunt.hcl   # Dev environment
    └── prod/
        └── terragrunt.hcl   # Prod environment
```

### Root Configuration

`terragrunt/terragrunt.hcl`:

```hcl
remote_state {
  backend = "s3"
  config = {
    bucket         = "terraform-state-${get_aws_account_id()}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

### Environment Configuration

`terragrunt/envs/dev/terragrunt.hcl`:

```hcl
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../infra/modules"
}

inputs = {
  environment = "dev"
  vpc_cidr    = "10.0.0.0/16"
}
```

### Terragrunt Commands

```bash
cd terragrunt/envs/dev/

# Initialize
terragrunt init

# Plan
terragrunt plan

# Apply
terragrunt apply

# Destroy
terragrunt destroy
```

### Run All (Multiple Modules)

```bash
cd terragrunt/envs/dev/

# Apply all modules
terragrunt run-all init
terragrunt run-all plan
terragrunt run-all apply

# Destroy all
terragrunt run-all destroy
```

## Terraform Workspaces

Alternative to Terragrunt for multi-environment:

```bash
# List workspaces
terraform workspace list

# Create workspace
terraform workspace new dev
terraform workspace new prod

# Switch workspace
terraform workspace select dev

# Apply
terraform apply
```

## Variables and Outputs

### Input Variables

```hcl
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}
```

### Variable Files

`dev.tfvars`:
```hcl
environment = "dev"
vpc_cidr    = "10.0.0.0/16"
```

Apply:
```bash
terraform apply -var-file=dev.tfvars
```

### Outputs

```hcl
output "vpc_id" {
  description = "The VPC ID"
  value       = aws_vpc.main.id
}
```

View:
```bash
terraform output
terraform output vpc_id
terraform output -json
```

## Linting and Validation

### Terraform Format

```bash
terraform fmt
terraform fmt -recursive
terraform fmt -check  # CI mode
```

### Validate

```bash
terraform validate
```

### TFLint

```bash
cd infra/
tflint --init
tflint
tflint --recursive
```

### TFSec (Security)

```bash
cd infra/
tfsec .
tfsec --format json .
```

### Checkov

```bash
cd infra/
checkov -d .
checkov -d . --framework terraform
```

## Common Workflows

### Create New Environment

```bash
# 1. Copy dev environment
cp -r terragrunt/envs/dev terragrunt/envs/staging

# 2. Update variables
vim terragrunt/envs/staging/terragrunt.hcl

# 3. Apply
cd terragrunt/envs/staging
terragrunt run-all apply
```

### Import Existing Resources

```bash
terraform import aws_s3_bucket.example my-bucket-name
```

### Debugging

```bash
# Enable detailed logs
export TF_LOG=DEBUG
terraform plan

# Disable logs
unset TF_LOG
```

### Graph Visualization

```bash
terraform graph | dot -Tpng > graph.png
```

## Pre-commit Hooks

Install hooks:

```bash
pre-commit install
```

Hooks run automatically on commit:
- `terraform fmt`
- `terraform validate`
- `tflint`
- `tfsec`
- `terraform-docs`

Run manually:
```bash
pre-commit run --all-files
```

## Terraform Documentation

Auto-generate docs:

```bash
cd infra/modules/vpc
terraform-docs markdown table . > README.md
```

## State Management

### List Resources

```bash
terraform state list
```

### Show Resource

```bash
terraform state show aws_vpc.main
```

### Move Resource

```bash
terraform state mv aws_instance.old aws_instance.new
```

### Remove Resource

```bash
terraform state rm aws_instance.example
```

### Pull State

```bash
terraform state pull > terraform.tfstate
```

### Lock State

```bash
# Manual lock (troubleshooting)
aws dynamodb put-item \
  --table-name terraform-state-lock \
  --item '{"LockID": {"S": "..."}, "Info": {"S": "..."}}'
```

### Unlock State

```bash
terraform force-unlock <lock-id>
```

## Best Practices

1. **Use modules** for reusability
2. **Remote state** with S3 + DynamoDB
3. **State locking** always enabled
4. **Version pinning** in `versions.tf`
5. **Workspaces or Terragrunt** for environments
6. **Pre-commit hooks** for quality
7. **Tag everything** for cost allocation
8. **Use data sources** for existing resources
9. **Outputs** for important values
10. **Never commit** `.tfstate` files

## Troubleshooting

### State Lock Issues

```bash
# List locks
aws dynamodb scan --table-name terraform-state-lock

# Force unlock
terraform force-unlock <lock-id>
```

### Provider Version Conflicts

```bash
rm .terraform.lock.hcl
terraform init -upgrade
```

### Module Source Changes

```bash
terraform init -upgrade
```

### Plan Shows Changes But None Expected

```bash
terraform refresh
terraform plan
```

---

**Next:** [05 - Amazon Bedrock](05-bedrock.md)
