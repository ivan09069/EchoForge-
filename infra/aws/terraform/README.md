# EchoForge AWS Backup Infrastructure

This Terraform configuration creates a secure, cost-optimized backup infrastructure on AWS.

## Resources Created

- **S3 Bucket**: Private, versioned backup storage with encryption
- **KMS Key**: Customer-managed encryption key with automatic rotation
- **IAM User**: Least-privilege user for backup operations
- **Lifecycle Rules**: Automatic transition to cheaper storage classes

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with admin credentials
- Unique S3 bucket name

## Usage

1. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` and set your unique bucket name:
   ```hcl
   bucket_name = "echoforge-backups-your-unique-suffix"
   ```

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Review the planned changes:
   ```bash
   terraform plan
   ```

5. Apply the configuration:
   ```bash
   terraform apply
   ```

6. Save the outputs (used by setup-gh-secrets.sh):
   ```bash
   terraform output
   ```

## Security Features

- **Encryption**: SSE-KMS encryption at rest with automatic key rotation
- **Versioning**: Enabled to protect against accidental deletions
- **Private Access**: All public access blocked
- **Least Privilege**: IAM user limited to necessary S3/KMS operations only

## Cost Optimization

- Transitions to STANDARD_IA after 30 days
- Transitions to GLACIER after 90 days
- Expires noncurrent versions after 365 days

## Outputs

The configuration outputs all necessary values for GitHub Actions setup:
- Bucket name and ARN
- KMS key ID and ARN
- IAM credentials (marked sensitive)
- AWS region

Use `terraform output -json` to retrieve all values programmatically.
