# EchoForge GCP Backup Infrastructure

This directory contains Terraform configuration for deploying GCP backup infrastructure for EchoForge.

## Resources Created

- **Cloud Storage Bucket**: Versioned storage with customer-managed encryption
- **KMS Key Ring**: Container for encryption keys
- **KMS Crypto Key**: Customer-managed encryption key with automatic rotation
- **Service Account**: Application identity with least-privilege access
- **IAM Bindings**: Least-privilege permissions for backup operations
- **Lifecycle Policies**: Automated cost optimization across storage classes

## Prerequisites

- Google Cloud SDK installed and configured (`gcloud auth login`)
- Terraform >= 1.0
- GCP project with billing enabled
- Appropriate IAM permissions to create resources
- Unique bucket name (lowercase, hyphens allowed, globally unique)

## Deployment

1. **Copy and configure variables:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars and set:
   #   - gcp_project_id
   #   - bucket_name (unique)
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Review planned changes:**
   ```bash
   terraform plan
   ```

4. **Apply configuration:**
   ```bash
   terraform apply
   ```

5. **Configure GitHub secrets** (see root scripts/setup-gh-secrets.sh)

## Security Features

- **Customer-Managed Encryption**: All data encrypted with Cloud KMS
- **Automatic Key Rotation**: Keys rotate every 90 days
- **Versioning**: Protection against accidental deletions
- **Least Privilege**: Service Account limited to necessary permissions
- **Uniform Bucket Access**: IAM-only access control (no ACLs)
- **Public Access Prevention**: Enforced at bucket level

## Outputs

After applying, Terraform provides:
- Bucket name and URL
- Service Account email and credentials (JSON key)
- KMS key details
- Project ID and region

These outputs are used by GitHub Actions for backup operations.

## Cost Optimization

Lifecycle management automatically:
- Moves objects to NEARLINE after 30 days
- Moves objects to COLDLINE after 90 days
- Moves objects to ARCHIVE after 180 days
- Deletes old versions (keeps 5 most recent)

## Required APIs

The following GCP APIs will be enabled:
- Cloud Storage API
- Cloud KMS API

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

**Warning**: This will permanently delete all backup data and infrastructure.

## Notes

- Service Account key is exported as base64-encoded JSON
- Decode before use: `echo $KEY | base64 -d > key.json`
- Store credentials securely in GitHub Secrets
- Never commit service account keys to version control
