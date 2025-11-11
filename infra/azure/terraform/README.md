# EchoForge Azure Backup Infrastructure

This directory contains Terraform configuration for deploying Azure backup infrastructure for EchoForge.

## Resources Created

- **Resource Group**: Container for all backup resources
- **Storage Account**: Geo-redundant storage with versioning and encryption
- **Blob Container**: Private container for backup files
- **Key Vault**: Secure storage for encryption keys and secrets
- **Service Principal**: Application identity with least-privilege access
- **Lifecycle Policy**: Automated cost optimization (Cool after 30 days, Archive after 90 days)

## Prerequisites

- Azure CLI installed and configured (`az login`)
- Terraform >= 1.0
- Azure subscription with appropriate permissions
- Unique storage account name (3-24 lowercase alphanumeric characters)

## Deployment

1. **Copy and configure variables:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars and set your unique storage_account_name
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

- **Encryption at Rest**: All data encrypted with customer-managed keys
- **Geo-redundant Storage**: Automatic replication across regions
- **Versioning**: Protection against accidental deletions
- **Least Privilege**: Service Principal limited to Storage Blob Data Contributor
- **HTTPS Only**: Enforced secure transfer
- **No Public Access**: Container and blobs are private

## Outputs

After applying, Terraform provides:
- Storage account name and access key
- Service Principal credentials (client ID and secret)
- Key Vault details
- Tenant and subscription IDs

These outputs are used by GitHub Actions for backup operations.

## Cost Optimization

Lifecycle management automatically:
- Moves blobs to Cool tier after 30 days
- Archives blobs after 90 days
- Deletes old versions after 365 days

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

**Warning**: This will permanently delete all backup data and infrastructure.
